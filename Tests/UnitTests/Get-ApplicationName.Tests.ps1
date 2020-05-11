Describe "Get-ApplicationName" -Tags 'Unit' {
    Context "Get-ApplicationName" {
        $Process = Get-ForegroundWindowProcess
        it -Name "Returned results" -Test { Get-ApplicationName -Process $Process | Should -Not -BeNullOrEmpty}
    } #EndContext

    Context "Get-ApplicationName with mocks" -Tag "Integration" {
        Mock Get-ForegroundWindowProcess {

        }
        $Process = Get-ForegroundWindowProcess
        it -Name "Returned results" -Test { Get-ApplicationName -Process $Process | Should -Not -BeNullOrEmpty }
    } #EndContext
}

