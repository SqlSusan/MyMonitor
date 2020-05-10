#$ForegroundWindowHandle
Describe "Get-ForegroundWindowHandle" -Tags 'Unit' {
    Context "Get-ForegroundWindowHandle" -Tags 'Unit' {
        it -Name "Returned results" -Test {Get-ForegroundWindowHandle | Should -Not -BeNullOrEmpty}
    } #EndContext
}