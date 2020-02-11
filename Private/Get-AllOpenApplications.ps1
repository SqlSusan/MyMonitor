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
Get-Process
#>
function Get-AllOpenApplications {
    [cmdletbinding()]
    Param()

    Try {
        #test if the custom type has already been added
        [user32] -is [Type] | Out-Null
    }
    catch {
        #type not found so add it

        Add-Type -typeDefinition @"
        using System;
        using System.Runtime.InteropServices;

        public class User32
        {
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
        }
"@
        #must left justify here-string closing @
    } #catch

    <#
get the process for the currently active foreground window as long as it has a value
greater than 0. A value of 0 typically means a non-interactive window. Also ignore
any Task Switch windows
#>

    (Get-Process).where( { $_.MainWindowHandle -eq ([user32]::GetForegroundWindow()) `
                                -and $_.MainWindowHandle -ne 0 `
                                -and $_.Name -ne 'Explorer' `
                                -and $_.Title -notmatch "Task Switching" })

                                Get-Process | select Name, ProcessName, MainWindowTitle, MainModule, StartTime, ExitTime, Responding `
                                            | where {$_.MainWindowHandle -ne 0}

(gwmi win32_service).PathName | select-object {$_.Split('\')[-1].Split(" ")[0]} `
                                | sort-object -Unique


} #end Get-ForegroundWindowProcess