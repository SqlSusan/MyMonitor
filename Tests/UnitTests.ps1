Describe 'Unit Tests' {

    #Import-PowerShellDataFile .\Get-Process.psd1

    #New-MockObject -Type Thing.Type

    #Assert-VerifiableMocks
    
    #Invoke-Pester -Tag bootstrap
    . .\Tests\ModuleLoad.Tests.ps1
    . .\Tests\UnitTests\Get-ForegroundWindowHandle.Tests.ps1
    . .\Tests\UnitTests\Get-ForegroundWindowProcess.Tests.ps1

    #Invoke-Pester -Script .\Tests\UnitTests\Get-ForegroundWindowProcess.Tests.ps1 -PesterOption 

    #Invoke-Pester -Tag Unit
    
} #EndDescribe

