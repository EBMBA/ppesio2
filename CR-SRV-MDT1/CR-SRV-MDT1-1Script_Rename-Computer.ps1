$NameComputer = "CR-SRV-MDT1"

Rename-Computer -NewName $NameComputer -Force
Restart-Computer