# "PrincipalSource is supported only by Windows 10, Windows Server 2016, 
#  and later versions of the Windows operating system. For earlier versions, the property is blank."
# ref: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.localaccounts/get-localgroupmember?view=powershell-5.1

function Test-PasswordNeverExpires {
    
    param()

    $property = "PasswordExpires"
    $group = "Administrators"
    $local_admin_users = Get-LocalAdminUsers $group

    if (!$local_admin_users) {
        OutputMsg "skip" $MyInvocation.MyCommand "Empty Local $group..."
        return
    }

    foreach ($local_admin_user in $local_admin_users) {
        # PasswordNeverExpires is True when the value of "PasswordExpires" is empty
        if (!$local_admin_user.$property) {
            OutputMsg "pass" $MyInvocation.MyCommand "$local_admin_user True"
        }
        else {
            OutputMsg "warn" $MyInvocation.MyCommand "$local_admin_user False"
        }
    }
}


Export-ModuleMember -Function *