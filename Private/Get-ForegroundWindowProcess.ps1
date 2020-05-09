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

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/


  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************
.Link
Get-Process
#>
function Get-ForegroundWindowProcess {
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
    $ForegroundWindow = [foregroundwindow]::New()
    $ForegroundWindow = (Get-Process).where( { $_.MainWindowHandle -eq ([user32]::GetForegroundWindow()) `
                -and $_.MainWindowHandle -ne 0 `
                -and $_.Name -ne 'Explorer' `
                -and $_.Title -notmatch "Task Switching" }) | `
        Select-Object MainWindowHandle, WindowTitle, ID, StartTime, Company, ProductVersion, MainModule

    return $ForegroundWindow


} #end Get-ForegroundWindowProcess