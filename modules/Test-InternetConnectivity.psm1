# All scripts need thease 2 lines below.
#$CurrentDir = Split-Path -Parent $MyInvocation.MyCommand.Path
#Import-Module -ErrorAction Stop "$CurrentDir\OutputMsg.psm1" -Force

function Get-ProxyServer {

    param()
    $result = Get-ItemProperty -Path "Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    if ($result.ProxyEnable) {
        return $result.ProxyServer
    }
    else {
        return 
    }
}

function Test-InternetConnectivity {

    param (
        [Parameter(Mandatory = $False)]
        [string]$url = 'google.co.jp'
    )
    try {

        $proxy_server = Get-ProxyServer
        if ($proxy_server) {
            try {
                $result = Test-NetConnection $proxy_server.split(":")[0] -Port $proxy_server.split(":")[1]
                if (!$result.TcpTestSucceeded) {
                    OutputMsg "fail" $MyInvocation.MyCommand "TCP connect to proxy server($proxy_server) failed."
                    return
                }
            }
            catch {
                OutputMsg "fail" $MyInvocation.MyCommand "$proxy_server $_.Exception.Message"
                return
            }
            $proxy_server = "http://" + $proxy_server
            $result  = (curl $url -Proxy $proxy_server -UseBasicParsing)
        }
        else {
            $result  = (curl $url -UseBasicParsing)
        }
        $rawcontent = $result.RawContent -split "`r`n" | Select-Object -First 1
        if ($result.StatusCode -eq 200) {
            OutputMsg "pass" $MyInvocation.MyCommand "$url $rawcontent $proxy_server"
        }
        else {
            OutputMsg "warn" $MyInvocation.MyCommand "$url $rawcontent $proxy_server"
        }
    }
    catch {
        OutputMsg "fail" $MyInvocation.MyCommand "$url $_.Exception.Message"
    }
}

Export-ModuleMember -Function *