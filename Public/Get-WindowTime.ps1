Function Get-WindowTime {

    <#
.Synopsis
Monitor time by active window
.Description
This script will monitor how much time you spend based on how long a given window is active. Monitoring will continue until one of the specified triggers is detected. 

By default monitoring will continue for 1 minute. Use -Minutes to specify a different value. You can also specify a trigger by a specific date and time or by detection of a specific process.
.Parameter Time
Monitoring will continue until this datetime value is met or exceeded.
.Parameter Minutes
The numer of minutes to monitor. This is the default behavior.
.Parameter ProcessName
The name of a process that you would see with Get-Process, e.g. Notepad or Calc. Monitoring will stop when this process is detected.
Parameter AsJob
Run the monitoring in a background job. Note that if you stop the job you will NOT have any results.
.Example
PS C:\> $data = Get-WindowTime -minutes 60

Monitor window activity for the next 60 minutes. Be aware that you won't get your prompt back until this command completes.
.Example
PS C:\> Get-WindowTime -processname calc -asjob

Start monitoring windows in the background until the Calculator process is detected.
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
Get-Process

#>

    [cmdletbinding(DefaultParameterSetName = "Minutes")]
    Param(
        [Parameter(ParameterSetName = "Time")]
        [ValidateNotNullorEmpty()]
        [DateTime]$Time,

        [Parameter(ParameterSetName = "Minutes")]
        [ValidateScript( { $_ -ge 1 })]
        [Int]$Minutes = 1,

        [Parameter(ParameterSetName = "Process")]
        [ValidateNotNullorEmpty()]
        [string]$ProcessName,

        [switch]$AsJob

    )

    Write-Verbose "[$(Get-Date)] Starting $($MyInvocation.Mycommand)"  

    #define a scriptblock to use in the While loop
    Switch ($PSCmdlet.ParameterSetName) {

        "Time" {    
            Write-Verbose "[$(Get-Date)] Stop monitoring at $Time"      
            [scriptblock]$Trigger = [scriptblock]::Create("(get-date) -ge ""$time""")
            Break
        }
        "Minutes" {
            $Quit = (Get-Date).AddMinutes($Minutes)
            Write-Verbose "[$(Get-Date)] Stop monitoring in $minutes minute(s) at $Quit"
            [scriptblock]$Trigger = [scriptblock]::Create("(get-date) -ge ""$Quit""")
            Break  
        }
        "Process" {
            If (Get-Process -name $processname -ErrorAction SilentlyContinue) {
                Write-Warning "The $ProcessName process is already running. Close it first then try again."
                #bail out
                Return
            }
            Write-Verbose "[$(Get-Date)] Stop monitoring after trigger $Processname"
            [scriptblock]$Trigger = [scriptblock]::Create("Get-Process -Name $ProcessName -ErrorAction SilentlyContinue")
            Break
        }

    } #switch

    #define the entire command as a scriptblock so it can be run as a job if necessary
    $main = {
        Param($sb)

        if (-Not ($sb -is [scriptblock])) {
            #convert $sb to a scriptblock
            Write-Verbose "Creating sb from $sb"
            $sb = [scriptblock]::Create("$sb")
        }

        #create a hashtable
        $hash = @{ }

        #create a collection of objects
        $objs = @()

        New-Variable -Name LastApp -Value $Null

        while ( -Not (&$sb) ) {

            $Process = Get-ForegroundWindowProcess

            [string]$app = $process.MainWindowTitle 

            if ( (-Not $app) -and $process.MainModule.Description ) {
                #if no title but there is a description, use that
                $app = $process.MainModule.Description
            }
            elseif (-Not $app) {
                #otherwise use the module name
                $app = $process.mainmodule.modulename
            }
      
            if ($process -and (($Process.MainWindowHandle -ne $LastProcess.MainWindowHandle) -or ($app -ne $lastApp )) ) {
                Write-Verbose "[$(Get-Date)] NEW App changed to $app"
        
                #record $last
                if ($LastApp) {
                    if ($objs.WindowTitle -contains $LastApp) {
                        #update same app that was previously found
                        Write-Verbose "[$(Get-Date)] updating existing object $LastApp"
              
                        $existing = $objs | where { $_.WindowTitle -eq $LastApp }
 
                        Write-Verbose "[$(Get-Date)] SW = $($sw.elapsed)"
                            
                        $existing.Time += $sw.Elapsed

                        #include a detail property object
               
                        $existing.Detail += [pscustomObject]@{
                            StartTime = $start
                            EndTime   = Get-Date
                            ProcessID = $lastProcess.ID
                            Process   = if ($LastProcess) { $LastProcess } else { $process }
                        }
                        Write-Verbose "[$(Get-Date)] Total time = $($existing.time)"
                    }
                    else {
                        #create new object

                        #include a detail property object
                        [pscustomObject]$detail = @{
                            StartTime = $start
                            EndTime   = Get-Date
                            ProcessID = $lastProcess.ID
                            Process   = if ($LastProcess) { $LastProcess } else { $process }
                        }
                        Write-Verbose "[$(Get-Date)] Creating new object for $LastApp"
                        Write-Verbose "[$(Get-Date)] Time = $($sw.elapsed)"

                        #get categories
                        $appCategory = (Select-XML -xml $MonitorCategories -xpath "//app[@name='$($LastMainModule.Description.Trim())']").node.parentnode.name
                
                        if (!$appcategory) {
                            $appCategory = "None"
                        }

                        #if there is no process description then use the product name
                        #for the application
                        if ($LastMainModule.Description -match "\w+") {
                            $theApp = $LastMainModule.Description
                        }
                        else {
                            $theApp = $LastMainModule.Product
                        }

                        $obj = New-Object -TypeName PSobject -Property @{
                            WindowTitle  = $LastApp
                            Application  = $theApp #$LastProcess.MainModule.Description
                            Product      = $LastMainModule.Product         #$LastProcess.MainModule.Product
                            Time         = $sw.Elapsed
                            Detail       = , ([pscustomObject]@{
                                    StartTime = $start
                                    EndTime   = Get-Date
                                    ProcessID = $lastProcess.ID
                                    Process   = if ($LastProcess) { $LastProcess } else { $process }
                                } )
                            Category     = $appCategory
                            Computername = $env:COMPUTERNAME
                    
                        }    

                        $obj.psobject.TypeNames.Insert(0, "My.Monitored.Window")
                        #add a custom type name

                        #add the object to the collection
                        $objs += $obj
                    } #else create new object
                } #if $lastApp was defined
                else {
                    Write-Verbose "You should only see this once"
                }

                #new Process with a window
                Write-Verbose "[$(Get-Date)] Start a timer"
                $SW = [System.Diagnostics.Stopwatch]::StartNew()     
                $start = Get-Date
  
                #set the last app
                $LastApp = $app
                #preserve process information
                $LastProcess = $Process
                $LastMainModule = $process.mainmodule

                #clear app just in case
                Remove-Variable app
            }
            Start-Sleep -Milliseconds 100

        } #while

        #update last app
        if ($objs.WindowTitle -contains $LastApp) {
            #update same app that was previously found
            Write-Verbose "[$(Get-Date)] processing last object"
            Write-Verbose "[$(Get-Date)] updating existing object for $LastApp"
            Write-Verbose "[$(Get-Date)] SW = $($sw.elapsed)"
            $existing = $objs | where { $_.WindowTitle -eq $LastApp }

            $existing.Time += $sw.Elapsed

            Write-Verbose "[$(Get-Date)] Total time = $($existing.time)"

            #include a detail property object
    
            $existing.Detail += [pscustomObject]@{
                StartTime = $start
                EndTime   = Get-Date
                ProcessID = $lastProcess.ID
                Process   = if ($LastProcess) { $LastProcess } else { $process }
            }
        }
        else {
            #create new object

            Write-Verbose "[$(Get-Date)] Creating new object"
            Write-Verbose "[$(Get-Date)] Time = $($sw.elapsed)"

            #get categories
            $appCategory = (Select-XML -xml $MonitorCategories -xpath "//app[@name='$($LastMainModule.Description.Trim())']").node.parentnode.name
                
            if (!$appcategory) {
                $appCategory = "None"
            }

            if ($LastMainModule.Description -match "\w+") {
                $theApp = $LastMainModule.Description
            }
            else {
                $theApp = $LastMainModule.Product
            }
            $obj = New-Object -TypeName PSobject -Property @{
                WindowTitle  = $LastApp
                Application  = $theApp #$LastProcess.MainModule.Description
                Product      = $LastMainModule.Product         #$LastProcess.MainModule.Product
                Time         = $sw.Elapsed
                Detail       = , ([pscustomObject]@{
                        StartTime = $start
                        EndTime   = Get-Date
                        ProcessID = $lastProcess.ID
                        Process   = if ($LastProcess) { $LastProcess } else { $process }
                    })
                Category     = $appCategory
                Computername = $env:COMPUTERNAME
            }    

            $obj.psobject.TypeNames.Insert(0, "My.Monitored.Window")
            #add a custom type name

            #add the object to the collection
            $objs += $obj
        } #else create new object

        $objs

        Write-Verbose "[$(Get-Date)] Ending $($MyInvocation.Mycommand)"  
    } #main


    if ($asJob) {
        Write-Verbose "Running as background job"
        Start-Job -ScriptBlock $main -ArgumentList @($Trigger) -InitializationScript { Import-Module MyMonitor }

    }
    else {
        #run it
        Invoke-Command -ScriptBlock $main -ArgumentList @($Trigger)
    }

} #end Get-WindowTime