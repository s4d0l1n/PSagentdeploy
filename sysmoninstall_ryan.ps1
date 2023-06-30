Write-Host "Sysmon Deployment Tool"
$computerListFile = Read-Host "Enter the name of the computer list file (ie: ComputerList.txt)"
$installerPath = Read-Host "Enter the installer base path UNC (ie: \\FILESERVER\TOOLS)"

# $computers = get-adcomputer -filter 'Name -like "SUPPLY-*"' -Properties Name
# $fileserverIP = "192.168.13.10"
$sysmonInstaller = "$installerPath\Sysmon.exe"
$sysmonConfig = "$installerPath\sysmon_config.xml"

Write-Host "Installer: $sysmonInstaller"
Write-Host "Config:    $sysmonConfig"

foreach ($line in Get-Content $computerListFile) {
    $agentName = $line.Trim()
    $arguments = "/accepteula -i C:\sysmon_config.xml" 

    Write-Output "Installing on $agentName"
    
    Try { Copy-Item $sysmonInstaller "\\$agentName\c$\" -Force }
    Catch { 
        Write-Output "Unable to copy Sysmon.exe to $agentName - Skipping"
        continue 
    }

    Try { Copy-Item $sysmonConfig "\\$agentName\c$\" -Force }
    Catch { 
        Write-Output "Unable to copy sysmon_config.xml to $agentName - Skipping"
        continue
    }

    Try { Invoke-Command -ComputerName $agentName -ScriptBlock { param($arguments) Start-Process "C:\sysmon.exe" -ArgumentList $arguments -Wait } -ArgumentList $arguments }
    Catch {
        Write-Output "Unable to launch Sysmon installer on $agentName - Skipping"
        continue
    }

   Invoke-Command -ComputerName $agentName -ScriptBlock { Remove-Item -Path C:\Sysmon.exe -Force }
   Invoke-Command -ComputerName $agentName -ScriptBlock { Remove-Item -Path C:\sysmon_config.xml -Force }

}
