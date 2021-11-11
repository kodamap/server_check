function Test-SecureChannel {

    param()
   
    if (!(Test-DomainJoined)) {
        OutputMsg "skip" $MyInvocation.MyCommand "This server is a workgroup computer"
        return
    }

    try {
        $result = Test-ComputerSecureChannel
    }
    catch {
        OutputMsg "fail" $MyInvocation.MyCommand $_.Exception.Message
        return
    }

    if ($result) {
        OutputMsg "pass" $MyInvocation.MyCommand $result
    }
    else {
        OutputMsg "warn" $MyInvocation.MyCommand $result
    }
}

Export-ModuleMember -Function *