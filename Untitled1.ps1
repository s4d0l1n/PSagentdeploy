$computers = get-adcomputer -filter 'Name -like "IT-*"' -Properties Name
$sysmonPath = "z:\Sysmon\Sysmon.exe"
$configPath = "z:\Sysmon\sysmon_config.xml"
foreach($computer in $computers){
$computerName = $computer.Name 
$arguments = "/accepteula -c sysmon_config.xml" 
Write-Output "installing to $computerName"

Copy-Item $sysmonPath "\\$computerName\c$\" -Force
Copy-Item $configPath "\\$computerName\c$\" -Force
Invoke-Command -ComputerName $computerName -ScriptBlock { param($arguments) Start-Process "C:\sysmon.exe" -ArgumentList $arguments -Wait } -ArgumentList $arguments }
