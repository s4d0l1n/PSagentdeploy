foreach ($line in Get-Content .\ComputerList.txt) {
    $computer = $line.Trim()
    Write-Host ""
}