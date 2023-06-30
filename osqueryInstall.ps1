$computers = get-adcomputer -filter 'Name -like "*"' -Properties Name
$fileserverIP = "192.168.13.10"
$osqueryPath = "\\$fileserverIP\Tools\osquery.msi"
$osqueryConfig = "\\$fileserverIP\Tools\launcher.flags"
$arguments = "/quiet"
foreach($computer in $computers){
$computerName = $computer.Name 
 
Write-Output "installing to $computerName"

Copy-Item $osqueryPath "\\$computerName\c$\" -Force
write-output "copied"
Invoke-Command -ComputerName $computerName -ScriptBlock { param($arguments) Start-Process "C:\osquery.exe" -ArgumentList $arguments -Wait} -ArgumentList $arguments
write-output "installed"
Copy-Item $osqueryConfig "\\$computerName\c$\Program Files\Kolide\Launcher-so-launcher\conf\" -Force
write-output "copied config"

Get-Service -Name LauncherSoLauncherSvc -ComputerName $computerName | Start-Service
write-output "service started"
}
