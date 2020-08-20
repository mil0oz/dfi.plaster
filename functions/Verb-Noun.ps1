<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Verb-Noun
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([string])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [string] $Param1,

        # Param2 help description
        [int] $Param2
    )

    Begin
    {
        $ErrorActionPreference = 'Stop'
    }
    Process
    {
        try
        {
            # something
        }
        catch
        {
            Write-PSFMessage -Level Critical -Message "" -ErrorRecord $_
            [Environment]::Exit(1)
        }
    }
    End
    {
    }
}