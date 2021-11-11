function Get-NumberOfCores () {
    param()
    $cpu = (Get-CimInstance -class CIM_Processor)
    return $cpu.numberofcores
}

function Get-PhysicalMemory {
    param ()
    $memory = Get-CimInstance -class CIM_PhysicalMemory
    return ($memory | Foreach-Object {$_.Capacity} | Measure-Object -Sum).Sum
}

function Get-SystemDisk {
    param ()
    $SystemDisk = Get-CimInstance -Class CIM_LogicalDisk | Select-Object * | Where-Object DeviceId -EQ 'C:'
    return @($SystemDisk.Size, $SystemDisk.FreeSpace)
}

function Test-ServerSpec {

    param (
        [Parameter(Mandatory = $false)]
        [int]$cores = 2,
        [Parameter(Mandatory = $false)]
        [int]$ram = 8,
        [Parameter(Mandatory = $false)]
        [int]$disk = 100,
        [Parameter(Mandatory = $false)]
        [int]$free = 30
    )

    try {
        $number_of_cpucores = Get-NumberOfCores
        if ($number_of_cpucores -ge $cores) {
            OutputMsg "pass" $MyInvocation.MyCommand "number of cores: $number_of_cpucores (>=$cores)"
        }
        else {
            OutputMsg "warn" $MyInvocation.MyCommand "number of cores: $number_of_cpucores (<$cores)"
        }
    }
    catch {
        OutputMsg "fail" $MyInvocation.MyCommand $_.Exception.Message
    }

    try {
        $memory_capacity = (Get-PhysicalMemory) / 1gb
        if (($memory_capacity) -ge $ram) {
            OutputMsg "pass" $MyInvocation.MyCommand "memory capacity(GB): $memory_capacity (>=$ram)"
        }
        else {
            OutputMsg "warn" $MyInvocation.MyCommand "memory capacity(GB): $memory_capacity (<$ram)"
        }
    }
    catch {
        OutputMsg "fail" $MyInvocation.MyCommand $_.Exception.Message
    }

    try {
        $disk_size = Get-SystemDisk
        $disk_capacity = [Math]::Truncate($disk_size[0]/1gb)
        $disk_free = [Math]::Truncate($disk_size[1]/1gb)

        if (($disk_capacity) -ge $disk) {
            OutputMsg "pass" $MyInvocation.MyCommand "disk capacity(GB): $disk_capacity (>=$disk)"
            if (($disk_free) -le $free) {
                OutputMsg "warn" $MyInvocation.MyCommand "disk free(GB): $disk_free (<$free)"
            }
        }
        else {
            OutputMsg "warn" $MyInvocation.MyCommand "disk capacity(GB): $disk_capacity (<$disk)"
        }
    }
    catch {
        OutputMsg "fail" $MyInvocation.MyCommand $_.Exception.Message
    }
}

Export-ModuleMember -Function *



