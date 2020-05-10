Describe "Module loading" -Tag "bootstrap" {
    Remove-Module MyMonitor -ErrorAction SilentlyContinue
    Import-Module .\MyMonitor.psm1
    $commands = Get-Command -Module MyMonitor

Context "Functions are loaded" {
        It "Get-ForegroundWindowProcess is loaded" { ($commands | where-object {$_.Name -eq "Get-ForegroundWindowProcess"}) | Should -BeTrue }
}

}