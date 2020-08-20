# dfi.plaster

## tl;dr

dfi.plaster is a plaster template for creating new PowerShell functions. It allows for a repeatable, universal function structure with components for building in Jenkins and publishing to the DFI Powershell gallery.

### How To Use

* Clone to your git folder
    * e.g. `D:\git\dfi.plaster`
* Execute the following from an elevated powershell session:
```sh
Import-Module Plaster -Scope Local

# set author name
$author = $env:USERNAME

# set module name
import-module plaster
$moduleName = 'MyFirstModule' # <----- module name

# declare parameter splat
$plaster = @{
    TemplatePath ="GIT:\dfi.plaster" # path to boiler plate local repo
    DestinationPath = "Env:\$moduleName" # ouput path for module
    FullName = "$($author.Substring(10))"
    ModuleName = "$($moduleName)"
    CompanyName = 'MyCompany'
    ModuleDesc = "Describe what your module is doing"
    Version = "0.0.1"
}

# create new module
If (!(Test-Path $plaster.DestinationPath)) {
    New-Item -ItemType Directory -Path $plaster.DestinationPath
}
Invoke-Plaster @plaster
```

This will generate a new module wireframe on your default profile path.

### Default function **structure**

By default the new module will be structured as:

```
ModuleName
|
    functions
        |
        |
            Verb-Noun.ps1
    internal
        |
            Verb-Noun.ps1
    tests
        |
            *.ps1
```

Functions that you want exposed and called by external processes/consumers should be placed in the `functions` folder.

*Support* functions should be nested in the `internal` folder. These are `not` exposed to the consumer.

The `tests` folder contains a number of default `Pester` tests that are executed during the build on the build server. They can be invoked from the cmdline during dev time via dot sourcing, for example:
`& .\tests\Help.Tests.ps1`

### CICD

To leverage a CICD pipeline using gitflow:
* create Jenkins job
* add git url to repository
* select _Build from Jenkinsfile_
* enter path to jenkinsfile (default is `jenkinsfile`)
* apply and create