# Microsoft recommend using Prefer IPv4 over IPv6 in prefix policies instead of disabling IPV6.
# - Prefer IPv4 over IPv6	Decimal 32(Hex 0x20)
# - Disable IPv6	Decimal 255 (Hex 0xFF)
# Ref:  https://docs.microsoft.com/en-us/troubleshoot/windows-server/networking/configure-ipv6-in-windows
function Test-PreferIpv4oIpv6 {

    param (
        [Parameter(Mandatory = $false)]
        [int32]$value = 0x20
    )

    $reg_path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
    $key = "DisabledComponents"
    try {
        $result = (Get-ItemProperty $reg_path).$key
    }
    catch {
        OutputMsg "fail" $MyInvocation.MyCommand $_.Exception.Message
    }

    if (!$result) {
        OutputMsg "skip" $MyInvocation.MyCommand "$reg_path.$key is not set"
    }
    if ($result -eq $Value) {
        OutputMsg "pass" $MyInvocation.MyCommand ("$key is " + [Convert]::ToString($result,16))
    }
    elseif ($result -eq 255) {
        OutputMsg "warn", $MyInvocation.MyCommand, ("$key is " + [Convert]::ToString($result,16))
    }
}

Export-ModuleMember -Function *