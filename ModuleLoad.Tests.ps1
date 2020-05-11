Describe "Module loading" -Tag "bootstrap" {

    Context "Functions are loaded" {
        get-module MyMonitor | Remove-Module;
        Import-Module $PSScriptRoot\MyMonitor.psm1;
        $commands = Get-Command -Module MyMonitor        
            It "Get-ForegroundWindowProcess is loaded" { `
                    ($commands | where-object { $_.Name -eq "Get-ForegroundWindowProcess" }) | Should -BeTrue }
    }
}
