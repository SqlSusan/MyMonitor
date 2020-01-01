Function Add-TimeSpan {
    <#
.Synopsis
Add timespan values

.Description
This command can be used to add timespan values. Measure-Object doesn't appear to be able to calculate a sum of timespans. The default output is a timespan object but you can also specify it as a string.

.Notes
Last Updated: May 31, 2016
Version     : 1.0

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************

.Link
Measure-WindowTotal

.Example
PS C:\> $d | measure-windowtotal -title -Filter facebook | Add-Timespan -verbose
VERBOSE: [BEGIN  ] Starting: Add-Timespan
VERBOSE: [PROCESS] Adding 00:00:07.0100396
VERBOSE: [PROCESS] Adding 00:00:22.4516731
VERBOSE: [PROCESS] Adding 00:03:02.5448095


Days              : 0
Hours             : 0
Minutes           : 3
Seconds           : 32
Milliseconds      : 6
Ticks             : 2120065222
TotalDays         : 0.00245377919212963
TotalHours        : 0.0588907006111111
TotalMinutes      : 3.53344203666667
TotalSeconds      : 212.0065222
TotalMilliseconds : 212006.5222

VERBOSE: [END    ] Ending: Add-Timespan

PS C:\> $d | measure-windowtotal -title -Filter facebook | Add-Timespan -AsString
00:03:32.0065222

#>

    [cmdletbinding()]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullorEmpty()]
        [Alias('totaltime', 'time')]
        [timespan]$Timespan,
        [switch]$AsString
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"  

        $Total = 0
    } #begin

    Process {
        Write-Verbose "[PROCESS] Adding $Timespan"
        $total += $Timespan
    } #process


    End {
        if ($AsString) {
            Write-Verbose "[END    ] Converting result to a string"
            $Total.ToString()
        }
        else {
            #write the full result
            $Total
        }
        Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
    } #end

}
