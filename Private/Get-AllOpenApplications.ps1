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

        $TypeDef = @"

using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;

namespace Api
{

 public class WinStruct
 {
   public string WinTitle {get; set; }
   public int WinHwnd { get; set; }
 }

 public class ApiDef
 {
   private delegate bool CallBackPtr(int hwnd, int lParam);
   private static CallBackPtr callBackPtr = Callback;
   private static List<WinStruct> _WinStructList = new List<WinStruct>();

   [DllImport("User32.dll")]
   [return: MarshalAs(UnmanagedType.Bool)]
   private static extern bool EnumWindows(CallBackPtr lpEnumFunc, IntPtr lParam);

    [DllImport("User32.dll")]
   [return: MarshalAs(UnmanagedType.Bool)]
   private static extern bool IsWindow(int hWnd);

   [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
   static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

   private static bool Callback(int hWnd, int lparam)
   {
        if (IsWindow(hWnd))
        {
            StringBuilder sb = new StringBuilder(256);
            int res = GetWindowText((IntPtr)hWnd, sb, 256);
            if (sb.Length > 0)
            {
                _WinStructList.Add(new WinStruct { WinHwnd = hWnd, WinTitle = sb.ToString() });
            }
        }
        return true;
   }   

   public static List<WinStruct> GetWindows()
   {
      _WinStructList = new List<WinStruct>();
      EnumWindows(callBackPtr, IntPtr.Zero);
      return _WinStructList;
   }

 }
}
"@
           
        Add-Type -TypeDefinition $TypeDef -Language CSharpVersion3

        [Api.Apidef]::GetWindows() | `
         Select-Object WinTitle, @{Name = "Handle"; Expression = { "{0:X0}" -f $_.WinHwnd}} | `
         fl

 

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
$service_exes = (gwmi win32_service).PathName | `
                                select-object @{N = "PathName"; E = {$_.Split('\')[-1].Split(" ")[0]}} `
                                | group-object {$_.PathName} `
                                | %{ $_.Name.Replace('"', "").Replace('.exe', "") }

    [user32].GetGenericArguments()

    (Get-Process).where( { $_.MainWindowHandle -eq ([user32]::GetForegroundWindow()) `
                                -and $_.MainWindowHandle -ne 0 `
                                -and $_.Name -ne 'Explorer' `
                                -and $_.Title -notmatch "Task Switching" })

                                Get-Process | select Name, ProcessName, MainWindowTitle, MainModule, StartTime, ExitTime, Responding `
                                            | where {$_.MainWindowHandle -ne 0 `
                                                    -and $_.ProcessName -notin $service_exes}
    @{ Name = ''; Expression = { } }

    $service_exes | %{ $_.Name.Replace('"', "").Replace('.exe', "") }

} #end Get-ForegroundWindowProcess