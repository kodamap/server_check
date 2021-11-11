function  Test-Firewallprofiles {

    param ()

    $firewall_profiles = @{
        'Domain' = ''
        'Private'= ''
        'Public' = ''
    }

    # copy dictionary for exception 
    # "An error occurred while enumerating through a collection: Collection was modified; enumeration operation may not execute"
    $firewall_profiles_copy = $firewall_profiles.Clone()
    try {
        foreach ($profile in $firewall_profiles_copy.keys) {
            $result = Get-NetFirewallprofile -Profile $profile
            $firewall_profiles[$profile] = $result.Enabled
        } 
    }
    catch {
        OutputMsg "fail" $MyInvocation.MyCommand $_.Exception.Message
    }
    if (!$firewall_profiles.ContainsValue('False')) {
        OutputMsg "pass" $MyInvocation.MyCommand "All profiles are enabled"
    }
    else {
        OutputMsg "warn" $MyInvocation.MyCommand ($firewall_profiles | ConvertTo-Json -Compress)
    }
}
Export-ModuleMember -Function *