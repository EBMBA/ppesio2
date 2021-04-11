$NamePlageIP = "Public"
$Mask = "255.255.240.0"
$Network = "172.16.0.0"
$StartRange = "172.16.0.1"
$EndRange = "172.16.15.253"
$Gateway = "172.16.15.254" 

$AdresseDNS = "172.16.33.1" 
$NameDomain = "CHL.loc"

Add-DHCPServerv4Scope -Name $NamePlageIP -StartRange $StartRange -EndRange $EndRange -SubnetMask $Mask -State Active
Set-DHCPServerv4OptionValue -ScopeID $Network  -DnsDomain $NameDomain -DnsServer $AdresseDNS -Router $Gateway
Add-DhcpServerInDC -DnsName $NameDomain -IpAddress $AdresseDNS
Get-DhcpServerv4Scope
Restart-service dhcpserver


$NamePlageIP = "ServiceOperationnels"
$Mask = "255.255.248.0"
$Network = "172.16.16.0"
$StartRange = "172.16.16.2"
$EndRange = "172.16.23.253"
$Gateway = "172.16.23.254" 

Add-DHCPServerv4Scope -Name $NamePlageIP -StartRange $StartRange -EndRange $EndRange -SubnetMask $Mask -State Active
Set-DHCPServerv4OptionValue -ScopeID $Network  -DnsDomain $NameDomain -DnsServer $AdresseDNS -Router $Gateway
Add-DhcpServerInDC -DnsName $NameDomain -IpAddress $AdresseDNS
Get-DhcpServerv4Scope
Restart-service dhcpserver


$NamePlageIP = "Laboratoire"
$Mask = "255.255.254.0"
$Network = "172.16.24.0"
$StartRange = "172.16.24.2"
$EndRange = "172.16.25.253"
$Gateway = "172.16.25.254" 

Add-DHCPServerv4Scope -Name $NamePlageIP -StartRange $StartRange -EndRange $EndRange -SubnetMask $Mask -State Active
Set-DHCPServerv4OptionValue -ScopeID $Network  -DnsDomain $NameDomain -DnsServer $AdresseDNS -Router $Gateway
Add-DhcpServerInDC -DnsName $NameDomain -IpAddress $AdresseDNS
Get-DhcpServerv4Scope
Restart-service dhcpserver


$NamePlageIP = "RechercheDeveloppement"
$Mask = "255.255.254.0"
$Network = "172.16.26.0"
$StartRange = "172.16.26.2"
$EndRange = "172.16.27.253"
$Gateway = "172.16.27.254" 

Add-DHCPServerv4Scope -Name $NamePlageIP -StartRange $StartRange -EndRange $EndRange -SubnetMask $Mask -State Active
Set-DHCPServerv4OptionValue -ScopeID $Network  -DnsDomain $NameDomain -DnsServer $AdresseDNS -Router $Gateway
Add-DhcpServerInDC -DnsName $NameDomain -IpAddress $AdresseDNS
Get-DhcpServerv4Scope
Restart-service dhcpserver


$NamePlageIP = "Radiologie"
$Mask = "255.255.254.0"
$Network = "172.16.28.0"
$StartRange = "172.16.28.2"
$EndRange = "172.16.29.253"
$Gateway = "172.16.29.254" 

Add-DHCPServerv4Scope -Name $NamePlageIP -StartRange $StartRange -EndRange $EndRange -SubnetMask $Mask -State Active
Set-DHCPServerv4OptionValue -ScopeID $Network  -DnsDomain $NameDomain -DnsServer $AdresseDNS -Router $Gateway
Add-DhcpServerInDC -DnsName $NameDomain -IpAddress $AdresseDNS
Get-DhcpServerv4Scope
Restart-service dhcpserver


$NamePlageIP = "Pharmacie"
$Mask = "255.255.254.0"
$Network = "172.16.30.0"
$StartRange = "172.16.30.2"
$EndRange = "172.16.31.253"
$Gateway = "172.16.31.254" 

Add-DHCPServerv4Scope -Name $NamePlageIP -StartRange $StartRange -EndRange $EndRange -SubnetMask $Mask -State Active
Set-DHCPServerv4OptionValue -ScopeID $Network  -DnsDomain $NameDomain -DnsServer $AdresseDNS -Router $Gateway
Add-DhcpServerInDC -DnsName $NameDomain -IpAddress $AdresseDNS
Get-DhcpServerv4Scope
Restart-service dhcpserver


$NamePlageIP = "Administration"
$Mask = "255.255.255.192"
$Network = "172.16.32.0"
$StartRange = "172.16.32.2"
$EndRange = "172.16.32.61"
$Gateway = "172.16.32.62" 

Add-DHCPServerv4Scope -Name $NamePlageIP -StartRange $StartRange -EndRange $EndRange -SubnetMask $Mask -State Active
Set-DHCPServerv4OptionValue -ScopeID $Network  -DnsDomain $NameDomain -DnsServer $AdresseDNS -Router $Gateway
Add-DhcpServerInDC -DnsName $NameDomain -IpAddress $AdresseDNS
Get-DhcpServerv4Scope
Restart-service dhcpserver


$NamePlageIP = "Accueil"
$Mask = "255.255.255.192"
$Network = "172.16.32.64"
$StartRange = "172.16.32.66"
$EndRange = "172.16.32.125"
$Gateway = "172.16.32.126" 

Add-DHCPServerv4Scope -Name $NamePlageIP -StartRange $StartRange -EndRange $EndRange -SubnetMask $Mask -State Active
Set-DHCPServerv4OptionValue -ScopeID $Network  -DnsDomain $NameDomain -DnsServer $AdresseDNS -Router $Gateway
Add-DhcpServerInDC -DnsName $NameDomain -IpAddress $AdresseDNS
Get-DhcpServerv4Scope
Restart-service dhcpserver


$NamePlageIP = "Informatique"
$Mask = "255.255.255.192"
$Network = "172.16.32.128"
$StartRange = "172.16.32.130"
$EndRange = "172.16.32.189"
$Gateway = "172.16.32.190" 

Add-DHCPServerv4Scope -Name $NamePlageIP -StartRange $StartRange -EndRange $EndRange -SubnetMask $Mask -State Active
Set-DHCPServerv4OptionValue -ScopeID $Network  -DnsDomain $NameDomain -DnsServer $AdresseDNS -Router $Gateway
Add-DhcpServerInDC -DnsName $NameDomain -IpAddress $AdresseDNS
Get-DhcpServerv4Scope
Restart-service dhcpserver


$NamePlageIP = "Direction"
$Mask = "255.255.255.224"
$Network = "172.16.32.192"
$StartRange = "172.16.32.194"
$EndRange = "172.16.32.221"
$Gateway = "172.16.32.222" 

Add-DHCPServerv4Scope -Name $NamePlageIP -StartRange $StartRange -EndRange $EndRange -SubnetMask $Mask -State Active
Set-DHCPServerv4OptionValue -ScopeID $Network  -DnsDomain $NameDomain -DnsServer $AdresseDNS -Router $Gateway
Add-DhcpServerInDC -DnsName $NameDomain -IpAddress $AdresseDNS
Get-DhcpServerv4Scope
Restart-service dhcpserver


$NamePlageIP = "RessourcesHumaines"
$Mask = "255.255.255.224"
$Network = "172.16.32.224"
$StartRange = "172.16.32.226"
$EndRange = "172.16.32.253"
$Gateway = "172.16.32.254" 

Add-DHCPServerv4Scope -Name $NamePlageIP -StartRange $StartRange -EndRange $EndRange -SubnetMask $Mask -State Active
Set-DHCPServerv4OptionValue -ScopeID $Network  -DnsDomain $NameDomain -DnsServer $AdresseDNS -Router $Gateway
Add-DhcpServerInDC -DnsName $NameDomain -IpAddress $AdresseDNS
Get-DhcpServerv4Scope
Restart-service dhcpserver
