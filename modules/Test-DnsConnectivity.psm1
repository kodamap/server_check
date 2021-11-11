function  Test-DnsConnectivity {

    param (
        [Parameter(Mandatory = $false)]
        [int]$port = 53
    )

    $server_addresses = (Get-DnsClientServerAddress -AddressFamily Ipv4).ServerAddresses

    if (-not($server_addresses)) {
            OutputMsg "fail" $MyInvocation.MyCommand "DNS resolvers not set"
    }
    foreach ($server_address in $server_addresses | Select-Object -Unique) {
        try {
            $result = Test-NetConnection $server_address -Port $port
        }
        catch {
            OutputMsg "fail" $MyInvocation.MyCommand $_.Exception.Message
        }
        if ($result.TcpTestSucceeded) {
            OutputMsg "pass" $MyInvocation.MyCommand "${server_address}:${port} OK"
        }
        else {
            OutputMsg "warn" $MyInvocation.MyCommand "${server_address}:${port} NG"
        }
    }
}

Export-ModuleMember -Function *