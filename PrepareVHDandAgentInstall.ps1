Write-Host "Remove the WinHTTP proxy" -ForegroundColor red -BackgroundColor white
netsh winhttp reset proxy

Write-Host "Set the disk SAN policy to Onlineall." -ForegroundColor red -BackgroundColor white
Set-StorageSetting -NewDiskPolicy OnlineAll

Write-Host "Set Coordinated Universal Time (UTC) time for Windows. Also set the startup type of the Windows time service (w32time) to Automatic." -ForegroundColor red -BackgroundColor white
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation' -Name "RealTimeIsUniversal" -Value 1 -Type DWord -Force
Set-Service -Name w32time -StartupType Automatic

Write-Host "Set the power profile to high performance." -ForegroundColor red -BackgroundColor white
powercfg /setactive SCHEME_MIN

Write-Host "Make sure the environmental variables TEMP and TMP are set to their default values" -ForegroundColor red -BackgroundColor white
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name "TEMP" -Value "%SystemRoot%\TEMP" -Type ExpandString -Force
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name "TMP" -Value "%SystemRoot%\TEMP" -Type ExpandString -Force

Write-Host "These services are the minimum that must be set up to ensure VM connectivity." -ForegroundColor red -BackgroundColor white
Get-Service -Name bfe | Where-Object { $_.StartType -ne 'Automatic' } | Set-Service -StartupType 'Automatic'
Get-Service -Name dhcp | Where-Object { $_.StartType -ne 'Automatic' } | Set-Service -StartupType 'Automatic'
Get-Service -Name dnscache | Where-Object { $_.StartType -ne 'Automatic' } | Set-Service -StartupType 'Automatic'
Get-Service -Name IKEEXT | Where-Object { $_.StartType -ne 'Automatic' } | Set-Service -StartupType 'Automatic'
Get-Service -Name iphlpsvc | Where-Object { $_.StartType -ne 'Automatic' } | Set-Service -StartupType 'Automatic'
Get-Service -Name netlogon | Where-Object { $_.StartType -ne 'Manual' } | Set-Service -StartupType 'Manual'
Get-Service -Name netman | Where-Object { $_.StartType -ne 'Manual' } | Set-Service -StartupType 'Manual'
Get-Service -Name nsi | Where-Object { $_.StartType -ne 'Automatic' } | Set-Service -StartupType 'Automatic'
Get-Service -Name TermService | Where-Object { $_.StartType -ne 'Manual' } | Set-Service -StartupType 'Manual'
Get-Service -Name MpsSvc | Where-Object { $_.StartType -ne 'Automatic' } | Set-Service -StartupType 'Automatic'
Get-Service -Name RemoteRegistry | Where-Object { $_.StartType -ne 'Automatic' } | Set-Service -StartupType 'Automatic'

Write-Host "Remote Desktop Protocol (RDP) is enabled." -ForegroundColor red -BackgroundColor white
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 -Type DWord -Force
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name "fDenyTSConnections" -Value 0 -Type DWord -Force

Write-Host "The RDP port is set up correctly. The default port is 3389." -ForegroundColor red -BackgroundColor white
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp' -Name "PortNumber" -Value 3389 -Type DWord -Force

Write-Host "The listener is listening in every network interface." -ForegroundColor red -BackgroundColor white
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp' -Name "LanAdapter" -Value 0 -Type DWord -Force

Write-Host "Configure the network-level authentication (NLA) mode for the RDP connections." -ForegroundColor red -BackgroundColor white
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 1 -Type DWord -Force
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "SecurityLayer" -Value 1 -Type DWord -Force
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "fAllowSecProtocolNegotiation" -Value 1 -Type DWord -Force

Write-Host "Set the keep-alive value." -ForegroundColor red -BackgroundColor white
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name "KeepAliveEnable" -Value 1  -Type DWord -Force
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name "KeepAliveInterval" -Value 1  -Type DWord -Force
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp' -Name "KeepAliveTimeout" -Value 1 -Type DWord -Force

Write-Host "RDP autoreconnect" -ForegroundColor red -BackgroundColor white
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name "fDisableAutoReconnect" -Value 0 -Type DWord -Force
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp' -Name "fInheritReconnectSame" -Value 1 -Type DWord -Force
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Winstations\RDP-Tcp' -Name "fReconnectSame" -Value 0 -Type DWord -Force

Write-Host "Remove any self-signed certificates tied to the RDP listener." -ForegroundColor red -BackgroundColor white
if ((Get-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp').Property -contains "SSLCertificateSHA1Hash") {
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "SSLCertificateSHA1Hash" -Force
}
Write-Host "Turn on Windows Firewall on the three profiles (domain, standard, and public)" -ForegroundColor red -BackgroundColor white
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

Write-Host "Allow WinRM through the three firewall profiles (domain, private, and public), and enable the PowerShell remote service." -ForegroundColor red -BackgroundColor white
Enable-PSRemoting -Force
Set-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)" -Enabled True

Write-Host "Enable the following firewall rules to allow the RDP traffic." -ForegroundColor red -BackgroundColor white
Set-NetFirewallRule -Group '@FirewallAPI.dll,-28752' -Enabled True

Write-Host "Enable the rule for file and printer sharing so the VM can respond to a ping command inside the virtual network." -ForegroundColor red -BackgroundColor white
Set-NetFirewallRule -Name FPS-ICMP4-ERQ-In -Enabled True

Write-Host "Set the Boot Configuration Data (BCD) settings." -ForegroundColor red -BackgroundColor white
bcdedit /set "{bootmgr}" integrityservices enable
bcdedit /set "{default}" device partition=C:
bcdedit /set "{default}" integrityservices enable
bcdedit /set "{default}" recoveryenabled Off
bcdedit /set "{default}" osdevice partition=C:
bcdedit /set "{default}" bootstatuspolicy IgnoreAllFailures

Write-Host "Enable Serial Console Feature." -ForegroundColor red -BackgroundColor white
bcdedit /set "{bootmgr}" displaybootmenu yes
bcdedit /set "{bootmgr}" timeout 5
bcdedit /set "{bootmgr}" bootems yes
bcdedit /ems "{current}" ON
bcdedit /emssettings EMSPORT:1 EMSBAUDRATE:115200

Write-Host "Enable the dump log collection." -ForegroundColor red -BackgroundColor white
# Set up the guest OS to collect a kernel dump on an OS crash event
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name CrashDumpEnabled -Type DWord -Force -Value 2
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name DumpFile -Type ExpandString -Force -Value "%SystemRoot%\MEMORY.DMP"
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name NMICrashDump -Type DWord -Force -Value 1

# Set up the guest OS to collect user mode dumps on a service crash event
$key = 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps'
if ((Test-Path -Path $key) -eq $false) {
    New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting' -Name LocalDumps | Out-Null
}
if (-not (Test-Path -Path 'C:\CrashDumps')) {
    New-Item -Path 'C:\CrashDumps' -ItemType Directory | Out-Null
}
New-ItemProperty -Path $key -Name DumpFolder -Type ExpandString -Force -Value "c:\CrashDumps"
New-ItemProperty -Path $key -Name CrashCount -Type DWord -Force -Value 10
New-ItemProperty -Path $key -Name DumpType -Type DWord -Force -Value 2
Set-Service -Name WerSvc -StartupType Manual

Write-Host "Verify that the Windows Management Instrumentation (WMI) repository is consistent." -ForegroundColor red -BackgroundColor white
winmgmt /verifyrepository

Write-Host "Checking if Agent installer is present" -ForegroundColor red -BackgroundColor white
$AgentInstallerPath = 'C:\agent.msi'
if (Test-Path -Path $AgentInstallerPath) {
    Write-Host "Removing old installer" -ForegroundColor red -BackgroundColor white
    Remove-Item -Path $AgentInstallerPath -Force -ErrorAction SilentlyContinue
}
else {
    Write-Host "Nothing to remove" -ForegroundColor red -BackgroundColor white
}

Write-Host "Find latest version" -ForegroundColor red -BackgroundColor white
# Get latest VM agent installer from the GitHub releases API.
$url = 'https://api.github.com/repos/Azure/WindowsVMAgent/releases/latest'
try {
    $release = Invoke-RestMethod -Uri $url -Headers @{ 'User-Agent' = 'PowerShell' } -ErrorAction Stop
    $asset = $release.assets |
        Where-Object { $_.name -match 'windowsazurevmagent.*\.msi$' } |
        Sort-Object -Property name -Descending |
        Select-Object -First 1

    if (-not $asset) {
        throw "Could not find a Windows Azure VM Agent MSI asset in the latest release."
    }

    $src = $asset.browser_download_url
}
catch {
    Write-Host "Failed to resolve latest VM agent installer: $_" -ForegroundColor red -BackgroundColor white
    exit 1
}

Write-Host "Download latest installer" -ForegroundColor red -BackgroundColor white
# Download installer
Invoke-WebRequest -Uri $src -OutFile $AgentInstallerPath -ErrorAction Stop

Write-Host "Installing VM agent" -ForegroundColor red -BackgroundColor white
Start-Process -FilePath $AgentInstallerPath -ArgumentList '/quiet' -Wait -NoNewWindow -ErrorAction Stop

# Wait for 30 seconds to allow the Azure VM agent to install
Write-Host "Waiting for agent to complete installation" -ForegroundColor red -BackgroundColor white
Start-Sleep -Seconds 30

Write-Host "Removing agent installer" -ForegroundColor red -BackgroundColor white
if (Test-Path -Path $AgentInstallerPath) {
    Write-Host "Removed agent installer" -ForegroundColor red -BackgroundColor white
    Remove-Item -Path $AgentInstallerPath -Force -ErrorAction SilentlyContinue
}
else {
    Write-Host "Nothing to remove" -ForegroundColor red -BackgroundColor white
}
