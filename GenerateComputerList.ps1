######
#
# GenerateComputerList.ps1
#
######

Get-ADComputer -Filter * -Properties Name | Format-Table Name | Out-File ComputerList.txt