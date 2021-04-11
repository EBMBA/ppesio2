$DomainName = "CHL.loc"
$Credential = "Administrator"

Add-Computer -DomainName $DomainName -Credential $Credential
Restart-Computer
