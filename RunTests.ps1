Get-Module MyMonitor | Remove-Module -ErrorAction SilentlyContinue
Import-Module .\MyMonitor.psm1

get-module pester | remove-module 
import-module pester -RequiredVersion 4.10.1

Invoke-Pester -Tag bootstrap
#Invoke-Pester -Tag Unit

. .\Tests\UnitTests\Get-ForegroundWindowProcess.Tests.ps1

