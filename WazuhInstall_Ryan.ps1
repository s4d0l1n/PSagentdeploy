# $computers = get-adcomputer -filter 'Name -like "SUPPLY*"' -Properties Name
# $fileserverIP = "192.168.13.10"

Write-Host "Wazuh Deployment Tool"
$computerListFile = Read-Host "Enter the name of the computer list file (ie: ComputerList.txt)"
$wazuhManagerIP = Read-Host "Enter the IP address of the Wazuh Manager"
$installerPath = Read-Host "Enter the installer base path UNC (ie: \\FILESERVER\TOOLS)"

$wazuhInstaller = "$installerPath\wazuh.msi"
$wazuhConfig = "$installerPath\ossec.conf"

# $wazuhInstaller = "\\$fileserverIP\Tools\wazuh.msi"
# $wazuhConf = "\\$fileserverIP\Tools\ossec.conf"
# $wazuhManagerIP = "192.168.99.2"

Write-Host "Installer: $wazuhInstaller"
Write-Host "Config:    $wazuhConfig"
Write-Host "Manager:   $wazuhManagerIP"

foreach ($line in Get-Content $computerListFile) {
    $agentName = $line.Trim()
    $arguments = "/q WAZUH_MANAGER='$wazuhManagerIP' WAZUH_AGENT_NAME='$agentName'"

    # can't use -i below as this creates conflicts when using NAT
    $registrationArgs = "-m $wazuhManagerIP"

    Write-Output "Installing on $agentName."

    Copy-Item $wazuhInstaller "\\$agentName\c$\" -Force
    
    Invoke-Command -ComputerName $agentName -ScriptBlock {param($arguments) Start-Process "c:\wazuh.msi" -ArgumentList $arguments -Wait } -ArgumentList $arguments
    Invoke-Command -ComputerName $agentName -ScriptBlock {param($registrationArgs) Start-Process "C:\Program Files (x86)\ossec-agent\agent-auth.exe" -ArgumentList $registrationArgs -Wait } -ArgumentList $registrationArgs 
    Copy-Item $wazuhConf "\\$agentName\c$\Program Files (x86)\ossec-agent\" -Force

    Get-Service -Name Wazuh -ComputerName $agentName | Restart-Service

    # Clean up installer

    Invoke-Command -ComputerName $agentName -ScriptBlock { Remove-Item -Path C:\wazuh.msi -Force }
}
