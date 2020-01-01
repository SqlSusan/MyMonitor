Function Get-WindowTimeSummary {
    <#
.Synopsis
Get a summary of window usage time
.Description
This command will take an array of window usage data and present a summary based on application. The output will include the total time as well as the first and last times for that particular application.

As an alternative you can get a summary by Product or you can filter using a regular expression pattern on the window title.
.Example
PS C:> 

PS C:\> Get-WindowTimeSummary $data

Name                              Total                        Start                            End
----                              -----                        -----                            ---
Windows PowerShell ISE            00:20:28.3669673             10/7/2015 8:07:09 AM             10/7/2015 10:36:36 AM
SugarSync                         00:00:11.3705429             10/7/2015 8:07:20 AM             10/7/2015 9:01:31 AM
Spotify                           00:04:25.0623684             10/7/2015 8:07:34 AM             10/7/2015 8:39:27 AM
Thunderbird                       00:17:38.3666410             10/7/2015 10:24:47 AM            10/7/2015 10:30:52 AM
COM Surrogate                     00:00:08.6499505             10/7/2015 8:09:51 AM             10/7/2015 8:10:00 AM
Waterfox                          01:20:46.0559866             10/7/2015 9:19:33 AM             10/7/2015 10:30:54 AM
Wireshark                         00:00:21.0674948             10/7/2015 8:13:23 AM             10/7/2015 8:29:48 AM
Virtual Machine Connection        00:02:07.3252447             10/7/2015 10:12:46 AM            10/7/2015 10:12:43 AM
Skype                             00:00:07.3145639             10/7/2015 8:29:27 AM             10/7/2015 8:39:12 AM
Windows PowerShell                00:00:33.6266261             10/7/2015 8:30:59 AM             10/7/2015 8:40:09 AM
Dropbox                           00:00:05.9456759             10/7/2015 8:32:26 AM             10/7/2015 8:32:32 AM
Microsoft Management Console      00:00:08.4824010             10/7/2015 8:39:45 AM             10/7/2015 10:12:46 AM
Microsoft Word                    00:22:18.5841682             10/7/2015 9:04:00 AM             10/7/2015 10:04:05 AM
Desktop Window Manager            00:00:05.5737147             10/7/2015 9:19:57 AM             10/7/2015 9:20:02 AM

Get time summary using the default application type.

.Example
PS C:\> Get-WindowTimeSummary $data -Type Product

Name                              Total                        Start                            End
----                              -----                        -----                            ---
Microsoft® Windows® Operating ... 00:23:32.0249043             10/7/2015 8:09:51 AM             10/7/2015 10:12:43 AM
SugarSync                         00:00:11.3705429             10/7/2015 8:07:20 AM             10/7/2015 9:01:31 AM
Spotify                           00:04:25.0623684             10/7/2015 8:07:34 AM             10/7/2015 8:39:27 AM
Thunderbird                       00:17:38.3666410             10/7/2015 10:24:47 AM            10/7/2015 10:30:52 AM
Waterfox                          01:20:46.0559866             10/7/2015 9:19:33 AM             10/7/2015 10:30:54 AM
Wireshark                         00:00:21.0674948             10/7/2015 8:13:23 AM             10/7/2015 8:29:48 AM
Skype                             00:00:07.3145639             10/7/2015 8:29:27 AM             10/7/2015 8:39:12 AM
Dropbox                           00:00:05.9456759             10/7/2015 8:32:26 AM             10/7/2015 8:32:32 AM
Microsoft Office 2013             00:22:18.5841682             10/7/2015 9:04:00 AM             10/7/2015 10:04:05 AM

Get time summary by product.
.Example
PS C:\> Get-WindowTimeSummary $data -filter "facebook|hootsuite"

Name                              Total                        Start                            End
----                              -----                        -----                            ---
facebook|hootsuite                00:28:22.3692839             10/7/2015 8:33:47 AM             10/7/2015 10:30:54 AM

Filter window titles with a regular expression.
.Notes
Last Updated: October 7, 2015
Version     : 2.0

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************

.Link
Get-WindowTime
Measure-WindowTotal
#>

    [cmdletbinding(DefaultParameterSetName = "Type")]
    Param(
        [Parameter(
            Position = 0, Mandatory,
            HelpMessage = "Enter a variable with your Window usage data")]
        [ValidateNotNullorEmpty()]
        $Data,
        [Parameter(ParameterSetName = "Type")]
        [ValidateSet("Product", "Application")]
        [string]$Type = "Application",

        [Parameter(ParameterSetName = "Filter")]
        [ValidateNotNullorEmpty()]
        [string]$Filter

    )

    Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"  


    if ($PSCmdlet.ParameterSetName -eq 'Type') {
        Write-Verbose "Processing on $Type"
        #filter out blanks and objects with multiple products from ALT-Tabbing
        $grouped = ($data).Where( { $_.$Type -AND $_.$Type.Count -eq 1 }) | Group-Object -Property $Type
    }
    else {
        #use filter
        Write-Verbose "Processing on filter: $Filter"
        $grouped = ($data).where( { $_.WindowTitle -match $Filter -AND $_.Product.Count -eq 1 }) |
        Group-Object -Property { $Filter }
    }

    if ($Grouped) {
        $grouped | Select Name,
        @{Name = "Total"; Expression = { 
                $_.Group | foreach -begin { $total = New-TimeSpan } -process { $total += $_.time } -end { $total }
            }
        },
        @{Name = "Start"; Expression = {
                ($_.group | sort Detail).Detail[0].StartTime
            }
        },
        @{Name = "End"; Expression = {
                ($_.group | sort Detail).Detail[-1].EndTime
            }
        }
    }
    else {
        Write-Warning "No items found"
    }

    Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"

} #end Get-WindowsTimeSummary