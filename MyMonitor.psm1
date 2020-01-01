﻿#requires -version 4.0

#region Commands

#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($Public + $Private)) {
  Try {
    . $import.fullname
  }
  Catch {
    Write-Error -Message "Failed to import function $($import.fullname): $_"
  }
}

# Export the Public modules
Export-ModuleMember -Function $Public.Basename

#endregion

#region TypeData

#set default display property set
Update-TypeData -TypeName "my.monitored.window" -DefaultDisplayPropertySet "Time","Application","WindowTitle","Product" -DefaultDisplayProperty WindowTitle -Force
Update-TypeData -TypeName "deserialized.my.monitored.window" -DefaultDisplayPropertySet "Time","Application","WindowTitle","Product" -DefaultDisplayProperty WindowTitle  -Force

#add an alias for the WindowTitle property
Update-TypeData -TypeName "My.Monitored.Window" -MemberType AliasProperty -MemberName Title -Value WindowTitle -force
Update-TypeData -TypeName "deserialized.My.Monitored.Window" -MemberType AliasProperty -MemberName Title -Value WindowTitle -force

#endregion

#region Aliases

Set-Alias -name mwt -Value Measure-WindowTotal
Set-Alias -name gfwp -Value Get-ForegroundWindowProcess
Set-Alias -Name gwt -Value Get-WindowTime
Set-Alias -name gwts -Value Get-WindowTimeSummary

#endregion

#region Variables

<#
Look for a copy of Categories.xml in the user's PowerShell directory and use that if found.
Otherwise use the one included with the module. This is to prevent overwriting the xml
file in future module updates.
#>

$localXML = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\WindowsPowerShell\Categories.xml"
$modXML = Join-Path -path $PSScriptroot -ChildPath categories.xml

if (Test-Path -path $localXML) {
    [xml]$MonitorCategories = Get-Content -Path $localXML
} 
else {
    [xml]$MonitorCategories = Get-Content -Path $modXML
}


#endregion

Export-ModuleMember -Function * -Alias * -Variable MonitorCategories

