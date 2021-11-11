$module_path = (Split-Path $PSScriptRoot) + "\modules"
$log_dir = Split-Path $PSScriptRoot
$yyyymmdd = Get-Date -Format "yyyyMMdd"
$max_msg_length = 90
$min_msg_length = 5

$modules = (Get-Module -ListAvailable "$module_path\*.psm1")
$Maxfunc_nameLength = (($modules.ExportedCommands | Foreach-Object  { 
    $_.keys.Length
}) | Measure-Object -Maximum).Maximum

Write-Information "Please wait. Working on server checking....." -InformationAction Continue

# for debug
# Write-Host $Maxfunc_nameLength $module_path

function OutputMsg {
   
    param([ValidateSet("pass", "warn", "fail", "skip")]$result, 
        $func_name,
        $msg,
        $log_name)

    $log_path = "${log_dir}\${env:COMPUTERNAME}_${yyyymmdd}.log"
    $now = Get-Date -Format "yyyy/MM/dd HH:mm:ss"

    if (($result -eq "pass")) {
        $result = $result.ToUpper() ; $foreground_color = "green"
    }
    elseif (($result -eq "warn")) {
        $result = $result.ToUpper() ; $foreground_color = "yellow"
    }
    elseif (($result -eq "fail")) {
        $result = $result.ToUpper() ; $foreground_color = "red"
    }
    elseif (($result -eq "skip")) {
        $result = $result.ToUpper() ; $foreground_color = "white"
    }

    if ($func_name.Length -le $Maxfunc_nameLength) {
        $func_name = "$func_name" + (" " * ($Maxfunc_nameLength - "$func_name".Length))    
    }
    $msgLength = "$now $func_name $msg [$result]".Length
    if ($msgLength -le $max_msg_length) {
        $dots = "." * ($max_msg_length - $msgLength)
    }
    else {
        $dots = "." * $min_msg_length 
    }
    $message = "| $now | $func_name | $msg $dots [$result] |"
    Write-Host $message -ForegroundColor $foreground_color
    Write-Output $message | Out-File ${log_path} -Append -Encoding Default
}

Export-ModuleMember -Function *