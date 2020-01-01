Function Measure-WindowTotal {

    <#
.Synopsis
Measure Window usage results.
.Description
This command is designed to take output from Get-WindowTime and measure total time either by Application, the default, by Product or Window title. Or you can elect to get the total time for all piped in measured window objects.

You can also filter based on keywords found in the window title. See examples.
.Parameter Filter
A string to be used for filtering based on the window title. The string can be a regular expression pattern.
.Example
PS C:\> $data = Get-WindowTime -ProcessName calc  

Start monitoring windows until calc is detected as a running process.

PS C:\> $data | Measure-WindowTotal

Application                                                        TotalTime
-----------                                                        ---------
Desktop Window Manager                                             00:00:05.5737147
Dropbox                                                            00:00:05.9456759
Skype                                                              00:00:07.3145639
Microsoft Management Console                                       00:00:08.4824010
COM Surrogate                                                      00:00:08.6499505
SugarSync                                                          00:00:11.3705429
Wireshark                                                          00:00:21.0674948
Windows PowerShell                                                 00:00:33.6266261
Virtual Machine Connection                                         00:02:07.3252447
Spotify                                                            00:04:25.0623684
Thunderbird                                                        00:17:38.3666410
Windows PowerShell ISE                                             00:20:28.3669673
Microsoft Word                                                     00:22:18.5841682
Waterfox                                                           01:20:46.0559866


PS C:\> $data  | Measure-WindowTotal -Product

Product                                                            TotalTime
-------                                                            ---------
Dropbox                                                            00:00:05.9456759
Skype                                                              00:00:07.3145639
SugarSync                                                          00:00:11.3705429
Wireshark                                                          00:00:21.0674948
Spotify                                                            00:04:25.0623684
Thunderbird                                                        00:17:38.3666410
Microsoft Office 2013                                              00:22:18.5841682
Microsoft® Windows® Operating System                               00:23:32.0249043
Waterfox                                                           01:20:46.0559866

The first command gets data from active window usage. The second command measures the results by Application. The last command measures the same data but by the product property.
.Example
PS C:\> $data | Measure-WindowTotal -filter "facebook" -TimeOnly

Days              : 0
Hours             : 0
Minutes           : 11
Seconds           : 2
Milliseconds      : 781
Ticks             : 6627813559
TotalDays         : 0.00767108050810185
TotalHours        : 0.184105932194444
TotalMinutes      : 11.0463559316667
TotalSeconds      : 662.7813559
TotalMilliseconds : 662781.3559

Get just the time that was spent on any window that had Facebook in the title.
.Example
PS C:\> $data | Measure-WindowTotal -filter "facebook|twitter"

Application                                                        TotalTime
-----------                                                        ---------
Desktop Window Manager                                             00:00:05.5737147
Waterfox                                                           00:10:57.2076412

Display how much time was spent on Facebook or Twitter.

.Example
PS C:\> Measure-WindowTotal $data -Category | Sort Time -descending | format-table -AutoSize

Category      Count Time
--------      ----- ----
Internet         68 01:25:18.4329189
Office            5 00:22:18.5841682
PowerShell        4 00:21:01.9935934
Test              1 00:20:28.3669673
Development       1 00:20:28.3669673
Mail             29 00:17:38.3666410
None              5 00:02:27.4945858
Utilities         2 00:00:29.5498958
Cloud             1 00:00:11.3705429
Communication     1 00:00:07.3145639

Measure window totals by category then sort the results by time in descending order. The result is formatted as a table.

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
#>

    [cmdletbinding(DefaultParameterSetName = "Product")]
    Param(
        [Parameter(Position = 0, ValueFromPipeline)]
        [Parameter(ParameterSetName = "Product")]
        [Parameter(ParameterSetName = "Title")]
        [Parameter(ParameterSetName = "Category")]
        [ValidateNotNullorEmpty()]
        $InputObject,
        [Parameter(ParameterSetName = "Product")]
        [Switch]$Product,
        [Parameter(ParameterSetName = "Title")]
        [Switch]$Title,
        [Parameter(ParameterSetName = "Category")]
        [Switch]$Category,
        [Parameter(ParameterSetName = "Product")]
        [Parameter(ParameterSetName = "Title")]
        [ValidateNotNullorEmpty()]
        [String]$Filter = ".*",
        [Parameter(ParameterSetName = "Product")]
        [Parameter(ParameterSetName = "Title")]
        [Switch]$TimeOnly
    )

    Begin {
        Write-Verbose "Starting $($MyInvocation.Mycommand)"  

        #initialize
        $hash = @{ }

        if ($Product) {
            $objFilter = "Product"
        }
        elseif ($Title) {
            $objFilter = "WindowTitle"
        }
        elseif ($Category) {
            $objFilter = "Category"
            #initialize an array to hold incoming items
            $data = @()
        }
        else {
            $objFilter = "Application"
        }

        Write-Verbose "Calculating totals by $objFilter"
    } #begin

    Process {

        foreach ($item in $InputObject) {
            #only process objects where the window title matches the filter which
            #by default is everything and there is only one object in the product
            #which should eliminate task switching data
            if ($item.WindowTitle -match $filter -AND $item.Product.count -eq 1) {

                If ($Category) {
                    $data += $item
                }
                else {
                    if ($hash.ContainsKey($item.$objFilter)) { 
                        #update an existing entry in the hash table
                        $hash.Item($item.$objFilter) += $item.Time 
                    }
                    else {
                        #Add an entry to the hashtable
                        Write-Verbose "Adding $($item.$objFilter)"
                        $hash.Add($item.$objFilter, $item.time)
                    }
                } #else not -Category
            }
        } #foreach
    } #process

    End {
        Write-Verbose "Processing data"

        if ($Category) {
            Write-Verbose "Getting category breakdown"
            $output = $data.category | select -Unique | foreach {
                $thecategory = $_
                $hash = [ordered]@{Category = $theCategory }
                $items = $($data).Where( { $_.category -contains $thecategory })
                $totaltime = $items | foreach -begin { $time = new-timespan } -process { $time += $_.time } -end { $time }
                $hash.Add("Count", $items.count)
                $hash.Add("Time", $TotalTime)
                [pscustomobject]$hash
            }
        }
        else {
            #turn hash table into a custom object and sort on time by default
            $output = ($hash.GetEnumerator()).foreach( {
                    [pscustomobject]@{$objfilter = $_.Name; "TotalTime" = $_.Value }
          
                }) | Sort TotalTime
        }

        if ($TimeOnly) {
            $output | foreach -begin { $total = New-TimeSpan } -process { $total += $_.Totaltime } -end { $total }
        }
        else {
            $output # | Select $objFilter,TotalTime
        }

        Write-Verbose "Ending $($MyInvocation.Mycommand)"
    } #end

} #end Measure-WindowTotal
