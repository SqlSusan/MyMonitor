<#
.Synopsis
Get process for foreground window process
.Description
This command will retrieve the process for the active foreground window, ignoring any process with a main window handle of 0.
It will also ignore Task Switching done with Explorer.
.Example
get-foregroundwindowprocess

MainWindowHandle : 394388
WindowTitle      :
Id               : 15948
StartTime        : 10/05/2020 13:51:04
Company          : Microsoft Corporation
ProductVersion   : 1.45.0
MainModule       : System.Diagnostics.ProcessModule (Code.exe)

.Notes

.Link
Get-Process
#>
function Get-ForegroundWindowProcess {
    [cmdletbinding()]
    Param()

    <#
get the process for the currently active foreground window as long as it has a value
greater than 0. A value of 0 typically means a non-interactive window. Also ignore
any Task Switch windows
#>
    $ForegroundWindow = [foregroundwindow]::New()
    $ForegroundWindow = (Get-Process) | Where-Object { $_.MainWindowHandle -eq (Get-ForegroundWindowHandle) `
                -and $_.MainWindowHandle -ne 0 `
                -and $_.Name -ne 'Explorer' `
                -and $_.Title -notmatch "Task Switching" } | `
        Select-Object MainWindowHandle, MainWindowTitle, ID, StartTime, Company, ProductVersion, MainModule

    return $ForegroundWindow


} #end Get-ForegroundWindowProcess