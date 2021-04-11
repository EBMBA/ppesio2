# Installer le service DHCP :
Install-WindowsFeature -Name DHCP -IncludeManagementTools

# Créer un security group :
netsh dhcp add securitygroups 
Restart-Service dhcpserver 
 
# Vérification de l'existence du serveur DHCP dans le DC : 
Get-DhcpServerInDC





#Source : https://www.kjctech.net/setting-up-active-directory-dns-and-dhcp-on-server-core-using-powershell/
#Source : https://medium.com/@malwareanimals/install-ad-ds-dns-and-dhcp-using-powershell-on-windows-server-2016-ac331e5988a7