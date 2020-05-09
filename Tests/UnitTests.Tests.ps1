Describe 'Unit Tests' -Tags 'Unit' {
    Mock -CommandName Get-Process { @{
            "MainWindowHandle" = "1246558"
            "WindowTitle" = ""
            "Id" = "9776"
            "StartTime" = "09/05/2020 21:45:11"
            "Company" = "Microsoft Corporation"
            "ProductVersion" = "1.45.0"
            "MainModule" = "System.Diagnostics.ProcessModule"
        }
}
    $ForegroundWindow = Get-Foregroundwindowprocess

    Context "Get-ForegroundWindowProcess" {
        it -Name "MainWindowHandle" -Test { $ForegroundWindow.MainWindowHandle | Should -be 1246558 }
        it -Name "WindowTitle" -Test { $ForegroundWindow.WindowTitle | Should -Be "" }
        it -Name "Id" -Test { $ForegroundWindow.Id | Should -Be "9776" }
        it -Name "StartTime" -Test { $ForegroundWindow.StartTime | Should -Be "09/05/2020 21:45:11" }
        it -Name "Company" -Test { $ForegroundWindow.Company | Should -Be "Microsoft Corporation" }
        it -Name "ProductVersion" -Test { $ForegroundWindow.ProductVersion | Should -Be "1.45.0" }
        it -Name "MainModule" -Test { $ForegroundWindow.MainModule | Should -Be "System.Diagnostics.ProcessModule" }
    }
}

