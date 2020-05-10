Describe "Module loading" -Tag "bootstrap" {
    $commands = Get-Command -Module MyMonitor
Context "Functions are loaded" {
        It "Get-ForegroundWindowProcess is loaded" { `
                ($commands | where-object { $_.Name -eq "Get-ForegroundWindowProcess" }) | Should -BeTrue }
}

}