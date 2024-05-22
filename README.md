- [1. What's this?](#1-whats-this)
- [2. Check list](#2-check-list)
- [3. How to Use](#3-how-to-use)
  - [3.1. Example](#31-example)
    - [3.1.1. Check from inside of the server](#311-check-from-inside-of-the-server)
    - [3.1.2. Check from outside of the server](#312-check-from-outside-of-the-server)
  - [3.2. Customize check modules](#32-customize-check-modules)
    - [3.2.1. Locate the module under the `modules`](#321-locate-the-module-under-the-modules)
    - [3.2.2. Add the check module to the main script.](#322-add-the-check-module-to-the-main-script)


# 1. What's this?

This is a server checking tool to reduce careless mistakes.

It checks the "should be" state from the inside of the server from a different perspective than the configuration test.

- You can use this on Windows Server 2016 and above. 
- No correction of setting values will be made.
- Define and evaluate "should be" states. No comparison with system specifications is made.
- Thus, there is no need to hardcode the setting value in the check module(script).
- It is positioned to complement the setting value confirmation(Unit test).



# 2. Check list

- Decide what state is `Pass`.
- Display 'Warn' to note "Is this configuration OK?"
- `()` means  the default parameters used by the check script to evaluate.

__Windows Server Check Profile__

| Category     | Check                        | Description                                                                                                                                                                         |
| ------------ | ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| State        | Ntp time sync                | Check if there is a time drift between a server and PDC Emulator in a domain environmet.<br>**Warning**, if there is a time drift.(`drift: 10 seconds`)                             |
|              | Secure Channel               | Check if there are no problems with computer's secure channel in domain environment (`True`)                                                                                        |
|              | ServerSpec<br>(CPU/RAM/Disk) | Check if the resource allocation is satisfied for server use(BaseLine). [^1]<br> (`BaseLine: 2Core, 8GB, 100GB`)                                                                    |
|              | Prefer IPv4 over IPv6        | Check if the setting of `Prefer IPv4 over IPv6`<br>**Warning**, if it is `disabled(0xFF) or it is other value`, if registory does not exists, `Skip`.  (`DisabledComponents: 0x20`) |
| Security     | UAC                          | Check if UAC is enabled. **Warning**, if it is `Disabled`                                                                                                                           |
|              | Firewall                     | Check if all profiles are turned on. <br>**Warning**, if one of them is `Disabled`                                                                                                  |
|              | Simple Password              | Check if a simple password is set for local admin accounts. <br>(Passw0rd, P@ssword)                                                                                                |
|              | PasswordNeverExpires         | Check if `PasswordNeverExpires` is enabled for the local administrator (`PasswordExpires: blank`) <br>**Warning**, if it is `Disabled`[^2]                                          |
|              | WindowsUpdate                | Check if AutoUpdate is Enabled(`NoAutoUpdate: 0`)<br>**Warning**, if it is `Disabled`                                                                                               |
| Connectivity | DNS Resolvers                | Connectivity check to DNS resolvers (`Port: Tcp/53`)[^3]                                                                                                                            |
|              | Internet                     | Connectivity check to the internet<br>If proxy is enabled, it automatically uses proxy server. (`Url:'google.co.jp'`)                                                               |


[^1]: Virtual machine configuration testing is performed on the virtualization infrastructure side. It's a complementary test.

[^2]: If you use complex passwords, periodic password changes for admin accounts are considered "unnecessary".

[^3]: It is especially important to check connectivity to the secondary.


# 3. How to Use

## 3.1. Example

### 3.1.1. Check from inside of the server

```ps
PS C:\server_check> powershell .\ServerCheck.ps1
Please wait. Working on server checking.....
| 2021/11/11 12:24:41 | Test-SecureChannel        | True ................................. [PASS] |
| 2021/11/11 12:24:41 | Test-DomainTimeSync       | Time sync OK (time drift: 0.0156282) . [PASS] |
| 2021/11/11 12:24:41 | Test-PreferIpv4oIpv6      | DisabledComponents is 20 ............. [PASS] |
| 2021/11/11 12:24:42 | Test-ServerSpec           | number of cores: 2 (>=2) ............. [PASS] |
| 2021/11/11 12:24:42 | Test-ServerSpec           | memory capacity(GB): 4 (<8) .......... [WARN] |
| 2021/11/11 12:24:43 | Test-ServerSpec           | disk capacity(GB): 39 (<100) ......... [WARN] |
| 2021/11/11 12:24:43 | Test-Firewallprofiles     | {"Private":0,"Domain":0,"Public":0} .. [WARN] |
| 2021/11/11 12:24:43 | Test-UACEnabled           | EnableLUA is not set ................. [SKIP] |
| 2021/11/11 12:24:44 | Test-PasswordNeverExpires | Administrator True ................... [PASS] |
| 2021/11/11 12:24:44 | Test-WindowsUpdateAU      | NoAutoUpdate is not set .............. [PASS] |
Please wait. checking simple password.....
| 2021/11/11 12:24:44 | Test-SimplePassword       | Administrator uses simple password: Passw0rd ..... [WARN] |
| 2021/11/11 12:24:46 | Test-DnsConnectivity      | x.x.x.x:53 OK ........................ [PASS] |
警告: TCP connect to (y.y.y.y : 53) failed
警告: Ping to y.y.y.y failed with status: TimedOut
| 2021/11/11 12:25:14 | Test-DnsConnectivity      | y.y.y.y:53 NG ........................ [WARN] |
| 2021/11/11 12:25:15 | Test-InternetConnectivity | google.co.jp HTTP/1.1 200 OK  ........ [PASS] |
```

### 3.1.2. Check from outside of the server

If you want to run it remotely, you need to distribute the script to the target server. No sepecial setting is required in a domain environment as long as WinRM (Windows Remote Management) service is running.[^4] 

```ps
PS C:\server_check> Invoke-Command -Computer server1 -ScriptBlock { C:\server_check\ServerCheck.ps1 }
```

[^4]: WinRM setting will be needed to be configured in a WORKGROUP environment.


## 3.2. Customize check modules

- Create a check module. (Recommend to use  [Approved Verbs](https://github.com/MicrosoftDocs/PowerShell-Docs/blob/staging/reference/docs-conceptual/developer/cmdlet/approved-verbs-for-windows-powershell-commands.md))
- Send the result to `OutPutMsg`
- `OutPutMsg` can receive `pass`, `warn`, `skip` and `fail`

```sh
function Test-XXXXX {
    param ()
    try {
        # add the check command
        <check>
    }
    catch {
        # send 'fail' to OutputMsg when exception occurs
        OutputMsg "fail" $MyInvocation.MyCommand $_.Exception.Message
    }

    if (condition) {
        # send `pass' when the result is succes
        OutputMsg "pass" $MyInvocation.MyCommand "<messages you want to display>"
    }
    else {
        # send `warn` when the result is not expected
        OutputMsg "warn" $MyInvocation.MyCommand "<messages you want to display>"
    }
}
Export-ModuleMember -Function *
```

### 3.2.1. Locate the module under the `modules`


```sh
server_check/
　├ ServerCheck.ps1 # main script
　├ modules/
　│　└ Test-DnsConnectivity.psm1 # .... this
　│　└ yyyy.psm1
　│　└ zzzz.psm1
..

```


### 3.2.2. Add the check module to the main script.

```ps
Import-Module $PSScriptRoot\lib\MsgOutputFormatter.psm1 -ErrorAction Stop
Get-Module -ListAvailable $PSScriptRoot\modules\*.psm1 | Import-Module -ErrorAction Stop

# Connectivity
Test-DNSConnectivity             #..... this
.
.
```

