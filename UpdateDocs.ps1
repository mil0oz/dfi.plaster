<#
.Synopsis
    Updates doc files
.DESCRIPTION
    Uses PlatyPS to generated .md document files in the docs folder.

    Prerequisites:
    * Modules PlatyPS and BuildHelpers

    It does the following:
    * Builds the module via ci\JenkinsBuild.ps1
    * Copies the module to the standard install folder (removing any previously installed modules)
    * Imports the module
    * Creates the document files
#>
$ErrorActionPreference="stop"

Import-Module PlatyPS
Import-Module BuildHelpers

Write-Host "Building module" -ForegroundColor Green
. $PSScriptRoot\ci\JenkinsBuild.ps1

$moduleName = Get-ProjectName $PSScriptRoot
$moduleInstallFolder = "C:\Program Files\WindowsPowerShell\Modules\$moduleName"
$moduleSource = $PSScriptRoot

Write-Host "Removing $moduleInstallFolder" -ForegroundColor Green
Remove-Item $moduleInstallFolder -Recurse -Force

Write-Host "Creating $moduleInstallFolder" -ForegroundColor Green
New-Item $moduleInstallFolder -ItemType Directory | Out-Null

Write-Host "Copying module to $moduleInstallFolder" -ForegroundColor Green
Copy-Item $moduleSource\* $moduleInstallFolder -Force -Recurse | Out-Null

Write-Host "Importing $moduleName" -ForegroundColor Green
Import-Module $moduleName

Write-Host "Creating documents" -ForegroundColor Green
$docsFolder = "$PSScriptRoot\docs"
Remove-Item $docsFolder\*.md
New-MarkdownHelp -Module $moduleName -OutputFolder $docsFolder -Force
