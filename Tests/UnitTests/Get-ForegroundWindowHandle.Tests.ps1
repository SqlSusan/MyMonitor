#$ForegroundWindowHandle
Describe "Get-ForegroundWindowHandle" -Tags 'Unit' {
    Context "Get-ForegroundWindowHandle" {
        it -Name "Returned results" -Test {Get-ForegroundWindowHandle | Should -Not -BeNullOrEmpty}
    } #EndContext
}