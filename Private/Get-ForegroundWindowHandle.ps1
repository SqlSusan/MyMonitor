<#
.Synopsis

.Description

.Example

.Notes

.Link

#>
function Get-ForegroundWindowHandle {
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

    return [user32]::GetForegroundWindow()

} #end Get-ForegroundWindowHandle