$ErrorActionPreference = 'STOP'

# Workspace
$workspace = $env:workspace
if (-not($workspace))
{
    # If $workspace not set, work it out relative to this script. Let's you test from a dev machine
    $workspace = Resolve-Path "$PSScriptRoot\.."
    Write-PSFMessage -Level Host "Workspace is $workspace"
}

# import buildhelpers module
try
{
    Import-Module BuildHelpers
    Write-PSFMessage -Level Host -Message "Imported BuildHelpers"
}
catch
{
    Write-PSFMessage -Level Critical -Message "Failed to import BuildHelpers" -ErrorRecord $_
    [Environment]::Exit(1)
}

# get module name from workspace
$moduleName = Get-ProjectName $workspace

# write variables to console
Write-PSFMessage -Level Host -Message "Building $moduleName"
Write-PSFMessage -Level Host "BHModulePath is $workspace"
Write-PSFMessage -Level Host "BHManifestPath is $workspace\$moduleName.psd1"
Write-PSFMessage -Level Host "Workspace is $workspace"

# version rule
$gvJson = ([string]$(GitVersion.exe $workspace))
if ($gvJson -like "INFO*")
{
    throw "GitVersion Error: $gvJson"
}
$gv = ConvertFrom-Json $gvJson
$script:BUILD_VERSION = $gv.MajorMinorPatch
$UrlToCommit = "https://bitbucket.org/<removed>/$moduleName/commits/$($gv.Sha)"

# check for manifest file
Write-PSFMessage -Level Host "Testing for manifest"
if (!(Test-Path $workspace\$moduleName.psd1))
{
    Write-PSFMessage -Level Host "No valid manifest to update, exiting"
    [Environment]::Exit()
}

# zero functions to export
[void]::(Update-ModuleManifest -Path "$workspace\$moduleName.psd1" -FunctionsToExport *)
Write-PSFMessage -Level Host "Updating functions to export"

# build list of public functions
$list = (Get-ChildItem -Path "$workspace\functions\*.ps1" |
        ForEach-Object -Process { [System.IO.Path]::GetFileNameWithoutExtension($_) })
[void]::($list | ForEach-Object { "'$_'" })
[void]::($list -join "','")

# pass list of functions to manifest
[void]::(Update-ModuleManifest -Path "$workspace\$moduleName.psd1" -FunctionsToExport $list)
Write-PSFMessage -Level Host -Message "Exported functions: $(Get-Metadata -Path "$workspace\$moduleName.psd1" -PropertyName FunctionsToExport)"

# Versioning
Write-PSFMessage -Level Host "Module build version: $($script:BUILD_VERSION)"
Update-ModuleManifest -Path "$workspace\$moduleName.psd1" -ModuleVersion "$script:BUILD_VERSION"

# Test manifest validity
Write-PSFMessage -Level Host "Testing manifest"
[void]::(Test-ModuleManifest -Path "$workspace\$moduleName.psd1" -ErrorAction Stop)
Write-PSFMessage -Level Host "Manifest test passed"

# write new version number to console
Write-PSFMessage -Level Host -Message "$moduleName module version: $(Get-Metadata -Path "$workspace\$moduleName.psd1")"

# Release Notes
$releaseNotes = $UrlToCommit
Write-PSFMessage -Level Host -Message "Release notes: $releaseNotes"
Update-ModuleManifest -Path "$workspace\$moduleName.psd1" -ReleaseNotes $releaseNotes

# update catalog file
Write-PSFMessage -Level Host -Message "Creating catalog"
$catalog = New-FileCatalog -Path $workspace -CatalogFilePath "$workspace\docs\$moduleName.cat" -CatalogVersion 2.0
Write-PSFMessage -Level Host -Message "Added catlog file: $($catalog)"