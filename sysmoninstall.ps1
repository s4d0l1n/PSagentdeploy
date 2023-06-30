$computers = get-adcomputer -filter 'Name -like "*"' -Properties Name
$fileserverIP = "192.168.13.10"
$sysmonPath = "\\$fileserverIP\Tools\Sysmon\Sysmon.exe"
$configPath = "\\$fileserverIP\Tools\Sysmon\sysmon_config.xml"
foreach($computer in $computers){ 
$computerName = $computer.Name 
$arguments = "/accepteula -i C:\sysmon_config.xml" 
Write-Output "installing to $computerName"

Copy-Item $sysmonPath "\\$computerName\c$\" -Force
Copy-Item $configPath "\\$computerName\c$\" -Force
Invoke-Command -ComputerName $computerName -ScriptBlock { param($arguments) Start-Process "C:\sysmon.exe" -ArgumentList $arguments -Wait } -ArgumentList $arguments }
