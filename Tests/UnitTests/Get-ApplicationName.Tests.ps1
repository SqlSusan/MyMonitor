Describe "Get-ApplicationName" -Tags 'Unit' {
    Context "Get-ApplicationName" {
        Mock -
        it -Name "Returned results" -Test { Get-ApplicationName | Should -Not -BeNullOrEmpty}
    } #EndContext
}