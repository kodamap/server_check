function Test-SimplePassword {

    param (
        [Parameter(Mandatory = $false)]
        [array]$passwd_list = @('Passw0rd', 'P@ssword', 'P@ssw0rd')
    )

    $group = "Administrators"
    $local_admin_users = Get-LocalAdminUsers $group

    if (!$local_admin_users) {
        OutputMsg "skip" $MyInvocation.MyCommand "Empty Local $group..."
        return
    }

    Write-Information "Please wait. checking simple password....." -InformationAction Continue
    foreach ($local_admin_user in $local_admin_users) {
        $count = 0
        foreach ($password in $passwd_list) {
            $cred = Get-SimpleCredential $local_admin_user $password
            # Access dined or 'pass' case shows PSRemotingTransportException , ignore this
            $result = Invoke-Command localhost -Credential $cred -ScriptBlock {whoami} -ErrorAction SilentlyContinue
            if ($null -eq $result) {
                continue
            }
            if ($result.ToLower().Contains($local_admin_user.Name.ToLower())) {
                OutputMsg "warn" $MyInvocation.MyCommand "$local_admin_user uses simple password: ${password}"
                $count +=1
            }
        }
        if ($count -eq 0) {
            OutputMsg "pass" $MyInvocation.MyCommand "$local_admin_user Simple passowrd not found."
        }
    }
}


Export-ModuleMember -Function *