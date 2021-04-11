$NameComputer = "CR-SRV-DC1"

Rename-Computer -NewName $NameComputer -Force
Restart-Computer