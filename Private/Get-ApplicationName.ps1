<#
.Synopsis

.Description

.Example
Get-ApplicationName -Process $Process

.Notes

.Link
#>
function Get-ApplicationName {
    [cmdletbinding()]
    Param($Process)

    [string]$app = $Process.MainWindowTitle 

    if ( (-Not $app) -and $Process.MainModule.Description ) {
        #if no title but there is a description, use that
        $app = $Process.MainModule.Description
    }
    elseif (-Not $app) {
        #otherwise use the module name
        $app = $Process.mainmodule.modulename
    }

    return $app

}