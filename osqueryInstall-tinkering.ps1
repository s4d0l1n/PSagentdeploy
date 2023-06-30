$computers = get-adcomputer -filter 'Name -like "DC-*"' -Properties Name
$fileserverIP = "192.168.13.10"
$osqueryPath = "\\$fileserverIP\Tools\osquery.msi"
$osqueryConfig = "\\$fileserverIP\Tools\launcher.flags"
$arguments = "/i 'C:\osquery.msi' /quiet"

foreach($computer in $computers){
$computerName = $computer.Name 
Write-Output "installing to $computerName"

Copy-Item $osqueryPath "\\$computerName\c$\" -Force
write-output "copied"

# Attempt #1
# Invoke-Command -ComputerName $computerName -ScriptBlock { param($arguments) Start-Process "C:\osquery.msi" -ArgumentList $arguments -Wait} -ArgumentList $arguments
# write-output "installed"
#

# Attempt 2
#
# $arguments = "/i 'C:\osquery.msi' /qn!"
# 
# Invoke-Command -ComputerName $computerName -ScriptBlock { param($arguments) Start-Process "msiexec.exe" -ArgumentList $arguments -Wait} -ArgumentList $arguments
# write-output "installed"
#


# Attempt #3
# 
# $session = New-PSSession -ComputerName $computer
# Invoke-Command -Session $session -ScriptBlock {Start-Process -FilePath "msiexec.exe" -ArgumentList "/i 'C:\osquery.msi' /quiet" -Wait}
# Remove-PSSession -Session $session
# write-output "installed"
# 

# Attempt #4

Invoke-Command -ComputerName $computerName -ScriptBlock {Start-Process "c:\osquery.msi" -ArgumentList "/qn /l* /log C:\bad.log" -Wait }


Copy-Item $osqueryConfig "\\$computerName\c$\Program Files\Kolide\Launcher-so-launcher\conf\" -Force
write-output "copied config"

Get-Service -Name LauncherSoLauncherSvc -ComputerName $computerName | Start-Service
write-output "service started"
}