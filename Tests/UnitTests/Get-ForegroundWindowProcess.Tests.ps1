    #$ForegroundWindowProcess
Describe "Get-ForegroundWindowProcess" -Tags 'Unit' {
    Mock -CommandName Get-Process `
    -MockWith { [PSCustomObject]@{
        "MainWindowHandle" = 1246558
        "WindowTitle"      = ""
        "Id"               = 9776
        "StartTime"        = (Get-Date).AddMinutes(-25)
        "Company"          = "Microsoft Corporation"
        "ProductVersion"   = "1.45.0"
        "MainModule"       = "System.Diagnostics.ProcessModule"
        "Title"            = ""
    } 
} -Verifiable

Mock -CommandName Get-ForegroundWindowHandle -MockWith { 1246558 } -Verifiable
    
    Context "Get-ForegroundWindowProcess with mocks" {


        $Process = Get-Process
        It "Mock Get-Process is returning results" -Test { $Process | Should -Not -BeNullOrEmpty }
        It "Mock Get-Process MainWindowHandle is correct" -Test { $Process.MainWindowHandle | Should -be 1246558 }
        It "Mock Get-ForegroundWindowHandle is correct" -Test { Get-ForegroundWindowHandle | Should -be 1246558 }
        It "Mock Get-ForegroundWindowHandle was used" { Assert-MockCalled -CommandName Get-ForegroundWindowHandle -Times 1 }

        #Mock -CommandName Get-ForegroundWindowHandle -MockWith { 1246558 } -Verifiable
        $ForegroundWindow = Get-ForegroundWindowProcess

        It -Name "Returned results" -Test { (,$ForegroundWindow).Count | Should -BeGreaterThan 0 }
        It -Name "MainWindowHandle" -Test { $ForegroundWindow.MainWindowHandle | Should -be 1246558 }
        It -Name "WindowTitle" -Test { $ForegroundWindow.WindowTitle | Should -Be "" }
        It -Name "Id" -Test { $ForegroundWindow.Id | Should -Be 9776 }
        It -Name "StartTime" -Test { $ForegroundWindow.StartTime | Should -BeLessThan (Get-Date).AddMinutes(-25) }
        It -Name "Company" -Test { $ForegroundWindow.Company | Should -Be "Microsoft Corporation" }
        It -Name "ProductVersion" -Test { $ForegroundWindow.ProductVersion | Should -Be "1.45.0" }
        It -Name "MainModule" -Test { $ForegroundWindow.MainModule | Should -Be "System.Diagnostics.ProcessModule" }

        It "Mock Get-ForegroundWindowHandle was used" { Assert-MockCalled -CommandName Get-ForegroundWindowHandle -Times 1 }
        It "Mock Get-Process was used" { Assert-MockCalled -CommandName Get-Process -Times 2 }
    } #EndContext
}