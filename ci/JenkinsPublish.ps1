# Line break for readability in AppVeyor console
Write-Host -Object ''

# Ensure pre reqs are loaded
if (! (Get-Module -Name BuildHelpers))
{
    Write-Host "Loading BuildHelpers module"
    Import-Module BuildHelpers
}

# Workspace
$workspace = $env:WORKSPACE
if (-not($workspace))
{
    # If $workspace not set, work it out relative to this script. Let's you test from a dev machine
    $workspace = Resolve-Path "$PSScriptRoot\.."
    Write-PSFMessage -Level Host "Workspace is $workspace"
}

# Publish variables
$script:ModuleName = Get-ProjectName $workspace
$script:Gallery = 'MyGallery'

# ensure DFIGallery registered
if (!((Get-PSRepository).Name -eq $script:Gallery))
{
    $galleryName="$script:Gallery"

    $a=Get-PSRepository

    if(!(($a).Name -contains "$galleryName"))
    {
        $repo = @{
        Name               = $galleryName
        InstallationPolicy = 'Trusted'
        SourceLocation     = '<nuget_feed>'
        }
        Register-PSRepository @repo
    }
}

Write-PSFMessage -Level Host -Message "Starting publish region"
Write-PSFMessage -Level Host -Message "Module is $script:ModuleName"

# Set tls encryption
try
{
    Write-PSFMessage -Level Host -Message "Changing security protocol to tls1.2"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}
catch
{
    Write-PSFMessage -Level Warning -Message "Failed to set security protocol"
    throw $_
    [Environment]::Exit(1)
}

# Git Branch
$git_branch = $env:GIT_BRANCH
if (! ($git_branch))
{
    # If $git_branch not set, get a sensible value. Let's you test from a dev machine
    $gv = ConvertFrom-Json ([string]$(GitVersion.exe $workspace))
    $git_branch = $gv.BranchName
}

try
{
    if ($git_branch -ne 'master')
    {
        # Mark this as a PreRelease module for non "master" branch builds
        #Update-ModuleManifest -Path $workspace\$moduleName.psd1 -Prerelease "-${git_branch}"
        Update-ModuleManifest -Path $workspace\$moduleName.psd1 -Tags "-${git_branch}"
    }

    Write-PSFMessage -Level Host -Message "Publishing to $script:Gallery"

    Publish-Module -Name ${workspace}\$moduleName.psd1 -Repository $script:Gallery

    Write-PSFMessage -Level Host -Message "Published"
}
catch
{
    Write-PSFMessage -Level Critical -Message $_ -ErrorRecord $_ -ErrorAction Stop
    [Environment]::Exit(1)
}
