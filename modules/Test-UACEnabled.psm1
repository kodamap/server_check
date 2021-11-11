# EnableLUA: User Account Control: Run all administrators in Admin Approval Mode
# Windows Server 2016 and above
# 0 = Disabled
# 1 (Default) = Enabled
# Ref: https://docs.microsoft.com/en-us/windows/security/identity-protection/user-account-control/user-account-control-group-policy-and-registry-key-settings 
function Test-UACEnabled {
    param (
        [Parameter(Mandatory = $false)]
        [int32]$value = 1
    )
    
    $reg_path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system"
    $key = "EnableLUA"
    try {
        $result = (Get-ItemProperty $reg_path).$key
    }
    catch {  
        OutputMsg "fail", $MyInvocation.MyCommand, $_.Exception.Message
        return
    }

    if (!$result) {
        OutputMsg "skip" $MyInvocation.MyCommand "$key is not set"
        return
    }
    if ($result -eq $Value) {
        OutputMsg "pass" $MyInvocation.MyCommand ("$key is " + [Convert]::ToString($result,16))
    }
    elseif ($result -eq 0) {
        OutputMsg "warn" $MyInvocation.MyCommand ("$key is " + [Convert]::ToString($result,16))
    }
}
    
Export-ModuleMember -Function *