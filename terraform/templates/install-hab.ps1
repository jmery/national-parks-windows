# $env:HAB_NONINTERACTIVE="true"
# $env:HAB_NOCOLORING="true"
$env:HAB_LICENSE="accept-no-persist"

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install habitat -y

# seen this randomly fail with flaky internet errors
# so try until we succeed
do {
  hab pkg install core/windows-service
}
until($LASTEXITCODE -eq 0)

hab pkg exec core/windows-service install
New-NetFirewallRule -DisplayName 'Habitat TCP' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9631,9638
New-NetFirewallRule -DisplayName 'Habitat UDP' -Direction Inbound -Action Allow -Protocol UDP -LocalPort 9638
Start-Service -Name Habitat
