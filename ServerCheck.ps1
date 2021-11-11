Import-Module $PSScriptRoot\libs\MsgOutputFormatter.psm1 -ErrorAction Stop
Import-Module $PSScriptRoot\libs\Utils.psm1 -ErrorAction Stop
Get-Module -ListAvailable $PSScriptRoot\modules\*.psm1 | Import-Module -ErrorAction Stop

# Modules

# State
Test-SecureChannel
Test-DomainTimeSync
Test-PreferIpv4oIpv6
Test-ServerSpec

# Security
Test-FirewallProfiles
Test-UACEnabled
Test-PasswordNeverExpires
Test-WindowsUpdateAU
Test-SimplePassword

# Connectivity
Test-DNSConnectivity
Test-InternetConnectivity