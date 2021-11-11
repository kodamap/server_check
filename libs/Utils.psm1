function Get-LocalAdminUsers () {
    param($group)

    try {
        $local_admin_users = Get-LocalGroupMember -Group $group | Where-Object {$_.PrincipalSource -match "Local"}
        if ($local_admin_users) {
            $local_admin_users = $local_admin_users | Foreach-Object {Get-Localuser $_.Name.split("\")[1]} | Where-Object {$_.Enabled -match "True"}
            return $local_admin_users
        }
        else {
            return
        }
    }
    catch {
        OutputMsg "fail" $MyInvocation.MyCommand $_.Exception.Message
        return
    }

}

function Get-SimpleCredential () {
    Param ($username, $password)
    $password = ConvertTo-SecureString -String $password -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password
    return $cred
}

function Test-DomainJoined () {
    return (Get-CimInstance -Class Win32_ComputerSystem).PartOfDomain
}


Export-ModuleMember -Function *