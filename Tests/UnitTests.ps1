Describe 'Unit Tests' {

    Get-Module MyMonitor | Remove-Module -ErrorAction SilentlyContinue
    Import-Module .\MyMonitor.psm1
    #Import-PowerShellDataFile .\Get-Process.psd1

    #New-MockObject -Type Thing.Type

    #Assert-VerifiableMocks
    get-module pester | remove-module 
    import-module pester -RequiredVersion 4.10.1

    get-command -Module pester

    #Invoke-Pester -Tag bootstrap
    Invoke-Pester -Tag bootstrap 
    
    . .\Tests\UnitTests\Get-ForegroundWindowHandle.Tests.ps1
    . .\Tests\UnitTests\Get-ForegroundWindowProcess.Tests.ps1

    #Invoke-Pester -Script .\Tests\UnitTests\Get-ForegroundWindowProcess.Tests.ps1 -PesterOption 

    Invoke-Pester -Tag Unit
    
} #EndDescribe

