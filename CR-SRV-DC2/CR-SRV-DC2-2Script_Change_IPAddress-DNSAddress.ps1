$IPAddress = "172.16.33.34"
$Prefix = "29"
$Gateway = "172.16.33.33"
$IPAddressDNS = "172.16.33.1"

New-NetIPAddress -IPAddress $IPAddress -PrefixLength $Prefix -InterfaceIndex (Get-NetAdapter).ifIndex -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter).ifIndex -ServerAddresses ($IPAddressDNS)