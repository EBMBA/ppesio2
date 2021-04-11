$IPAddress = "172.16.33.21"
$Prefix = "27"
$Gateway = "172.16.33.28"
$IPAddressDNS = "172.16.33.1"

New-NetIPAddress -IPAddress $IPAddress -PrefixLength $Prefix -InterfaceIndex (Get-NetAdapter).ifIndex -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter).ifIndex -ServerAddresses ($IPAddressDNS)