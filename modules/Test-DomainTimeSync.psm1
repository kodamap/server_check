function Get-LocalTime () {
    param($computer_name)
    $lt = Get-WmiObject -Class Win32_Localtime -ComputerName $computer_name
    return (Get-Date -Day $lt.Day -Month $lt.Month -Year $lt.Year -Minute $lt.Minute -Hour $lt.Hour -Second $lt.Second)
}

function Test-DomainTimeSync () {

    param (
        [Parameter(Mandatory = $false)]
        [int]$drift = 10
    )

    if (Test-DomainJoined) {
        $pdc = netdom query fsmo | findstr "PDC"
        $pdc = $pdc.split("PDC")[-1].replace(" ","")
        if ($pdc) {
            try {
                $time_drift =  ((Get-LocalTime $pdc) - (Get-LocalTime localhost)).TotalSeconds *(-1)
            }
            catch {
                OutputMsg "fail" $MyInvocation.MyCommand $_.Exception.Message
                return
            }
            if ($time_drift -lt $drift) {
                OutputMsg "pass" $MyInvocation.MyCommand "Time sync OK (time drift: ${time_drift})"
            }
            else {
                OutputMsg "warn" $MyInvocation.MyCommand "A time drift of $time_drift seconds exists between this server and $pdc"
            }
        }
        else {
            OutputMsg "fail" $MyInvocation.MyCommand "PDC Emulator not found"
        }
    }
    else {
        OutputMsg "skip" $MyInvocation.MyCommand "This server is a workgorup computer"
    }
}
