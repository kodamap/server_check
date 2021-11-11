# NoAutoUpate
# 0: Auto update is enabled 
# 1: Auto update is disabled

function Test-WindowsUpdateAU {
    
    param ()

    $reg_path = "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $key = "NoAutoUpdate"

    if (!(Test-Path -LiteralPath $reg_path)) {
        OutputMsg "skip" $MyInvocation.MyCommand "$reg_path not found"
        return
    }

    try {
        $result = (Get-ItemProperty $reg_path).$key
    }
    catch {
        OutputMsg "fail" $MyInvocation.MyCommand $_.Exception.Message
        return
    }

    if ($result -eq 0) {
        OutputMsg "pass" $MyInvocation.MyCommand "$key is $result(enabled)"
    }
    elseif (!$result) {
        OutputMsg "pass" $MyInvocation.MyCommand "$key is not set"
    }
    elseif ($result -eq 1) {
        OutputMsg "warn" $MyInvocation.MyCommand "$key is $result(disabled)"
    }
    else {
        OutputMsg "warn" $MyInvocation.MyCommand "$key is $result(unexpeced value)"
    }
}

Export-ModuleMember -Function *