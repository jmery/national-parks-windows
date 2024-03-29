<powershell>
# First, make sure WinRM can't be connected to
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=block

# set administrator password and enable account
$admin = [adsi]("WinNT://./administrator, user")
$admin.psbase.invoke("SetPassword", "${admin_password}")
Get-LocalUser -Name "Administrator" | Enable-LocalUser

# Delete any existing WinRM listeners
winrm delete winrm/config/listener?Address=*+Transport=HTTP  2>$Null
winrm delete winrm/config/listener?Address=*+Transport=HTTPS 2>$Null

# Create a new WinRM listener and configure
winrm create winrm/config/listener?Address=*+Transport=HTTP
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="0"}'
winrm set winrm/config '@{MaxTimeoutms="7200000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service '@{MaxConcurrentOperationsPerUser="12000"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'

# Configure UAC to allow privilege elevation in remote shells
$Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$Setting = 'LocalAccountTokenFilterPolicy'
Set-ItemProperty -Path $Key -Name $Setting -Value 1 -Force

# turn off PowerShell execution policy restrictions
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine

# Configure and restart the WinRM Service; Enable the required firewall exception
Stop-Service -Name WinRM
Set-Service -Name WinRM -StartupType Automatic
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new action=allow localip=any remoteip=any
Start-Service -Name WinRM

# Create a hab user and add them to the admin group
# cmd.exe /c net user hab ${hab_password} /add /LOGONPASSWORDCHG:NO
# cmd.exe /c net localgroup Administrators /add hab
# cmd.exe /c wmic useraccount where "name='hab'" set PasswordExpires=FALSE

</powershell>