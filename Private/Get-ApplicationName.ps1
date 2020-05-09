<#
.Synopsis
Get process for foreground window process
.Description
This command will retrieve the process for the active foreground window, ignoring any process with a main window handle of 0.

It will also ignore Task Switching done with Explorer.
.Example
PS C:\> get-foregroundwindowprocess

Handles  NPM(K)    PM(K)      WS(K) VM(M)   CPU(s)     Id ProcessName                                
-------  ------    -----      ----- -----   ------     -- -----------                                
    538      57   124392     151484   885    34.22   4160 powershell_ise

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