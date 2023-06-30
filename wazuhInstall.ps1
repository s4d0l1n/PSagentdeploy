$computers = get-adcomputer -filter 'Name -like "SUPPLY*"' -Properties Name
$fileserverIP = "192.168.13.10"
$wazuhInstaller = "\\$fileserverIP\Tools\wazuh.msi"
$wazuhConf = "\\$fileserverIP\Tools\ossec.conf"
$wazuhManagerIP = "192.168.99.2"

foreach($computer in $computers){
$computerName = $computer.Name 
$arguments = "/q WAZUH_MANAGER='$wazuhManagerIP' WAZUH_AGENT_NAME='$computerName'"

# can't use -i below as this creates conflicts when using NAT
$registrationArgs = "-m $wazuhManagerIP"

write-output "---------$computerName----------"
Write-Output "installing to $computerName with $wazuhInstaller"

Copy-Item $wazuhInstaller "\\$computerName\c$\" -Force

Invoke-Command -ComputerName $computerName -ScriptBlock {param($arguments) Start-Process "c:\wazuh.msi" -ArgumentList $arguments -Wait } -ArgumentList $arguments

Invoke-Command -ComputerName $computerName -ScriptBlock {param($registrationArgs) Start-Process "C:\Program Files (x86)\ossec-agent\agent-auth.exe" -ArgumentList $registrationArgs -Wait } -ArgumentList $registrationArgs 
copy-item $wazuhConf "\\$computerName\c$\Program Files (x86)\ossec-agent\" -Force

Get-Service -Name Wazuh -ComputerName $computerName | Restart-Service

write-output "-------------------"
}
