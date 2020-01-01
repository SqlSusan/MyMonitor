
Function Get-ComputerLocked {

    <#
.Synopsis
Returns whether the computer is locked or not

.Description

.Example
Get-ComputerLocked

.Notes
Last Updated: 1 January 2019
Version     : 1.0

.Link

#>

    [cmdletbinding(DefaultParameterSetName = "Minutes")]

    $currentuser = "$env:UserDomain\$env:UserName"
    $process = get-process logonui -ea silentlycontinue

    if ($currentuser -and $process) { 
        $IsLocked = 1 
    }
    else { 
        $IsLocked = 0
    }

    return $IsLocked

}