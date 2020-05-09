class processdetail {
    [ValidateNotNullOrEmpty()][datetime]$StartTime
    [ValidateNotNullOrEmpty()][datetime]$EndTime
    [ValidateNotNullOrEmpty()][int]$ProcessID
    [ValidateNotNullOrEmpty()][string]$Process

    processdetail($StartTime, $LastProcess, $process) {
        $this.StartTime = $StartTime 
        $this.EndTime = Get-Date
        $this.ProcessID = $lastProcess.ID
        $this.Process = if ($LastProcess) { $LastProcess } else { $process }
    }
}

class processreport {
    [ValidateNotNullOrEmpty()][string]$WindowTitle
    [ValidateNotNullOrEmpty()][string]$Application
    [ValidateNotNullOrEmpty()][string]$Product
    [ValidateNotNullOrEmpty()][datetime]$Time
    [ValidateNotNullOrEmpty()][processdetail]$Detail
    [ValidateNotNullOrEmpty()][string]$Category
    [ValidateNotNullOrEmpty()][string]$Computername

    processes($WindowTitle, $Application, $Product, $Time, $Detail, $Category, $Computername) {
        $this.WindowTitle = $WindowTitle 
        $this.Application = $Application 
        $this.Product = $Product 
        $this.Time = $Time 
        $this.Detail = $Detail 
        $this.Category = $Category
        $this.Computername = $env:COMPUTERNAME
    }
}

class foregroundwindow {
    [string]$MainWindowHandle
    [string]$WindowTitle
    [ValidateNotNullOrEmpty()][int]$ID
    [ValidateNotNullOrEmpty()][datetime]$StartTime
    [string]$Company
    [string]$ProductVersion
    [ValidateNotNullOrEmpty()][PSObject]$MainModule
}
