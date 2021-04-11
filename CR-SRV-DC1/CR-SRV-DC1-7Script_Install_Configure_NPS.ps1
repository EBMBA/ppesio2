Install-WindowsFeature NPAS -IncludeManagementTools

# Create Radius clients within csv doc 
$RadiusClientFile = Import-CSV -Delimiter "," -Path "C:\Liste_AP.csv"
$SharedSecret = "MonSecretPartageDeFou"

Foreach($ClientRadius in $RadiusClientFile){
    New-NpsRadiusClient -Address $ClientRadius.IPAddress -Name $ClientRadius.Name -SharedSecret $SharedSecret
 }

# Create group of user which they will can connect throught captive portal
$fqdn = Get-ADDomain
$fulldomain = $fqdn.DNSRoot
$domain = $fulldomain.split(".")
$Dom = $domain[0]
$Ext = $domain[1]

New-ADOrganizationalUnit -Name "Public" -Description "Croix-Rousse Public"  -Path "OU=Croix-Rousse,OU=Sites,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false

for ($i = 0; $i -lt 4000; $i++) {
    $Name = "Public"+$i
    New-ADUser -Name $Name -Path "OU=Public,OU=Croix-Rousse,OU=Sites,DC=$Dom,DC=$EXT" -UserPrincipalName $Name -Description "Public Account num $i" -AccountPassword (ConvertTo-SecureString "123+aze" -AsPlainText -Force) -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Enabled $true
}

New-ADGroup -Name "G_Public" -DisplayName "G_Public" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,DC=$Dom,DC=$EXT" -Description "Groupe Global Public"

$Users = Get-ADUser -Filter * -SearchBase "OU=Public,OU=Croix-Rousse,OU=Sites,dc=$Dom,dc=$Ext" 

foreach ($User in $Users) {
    Add-ADGroupMember -Identity "G_Public" -Members $User
}

$Users = Get-ADUser -Filter * -SearchBase "OU=Informatique,OU=Croix-Rousse,OU=Sites,dc=$Dom,dc=$Ext" 

foreach ($User in $Users) {
    Add-ADGroupMember -Identity "G_Informatique" -Members $User
}


$Users = Get-ADUser -Filter * -SearchBase "OU=Services Operationnels,OU=Croix-Rousse,OU=Sites,dc=$Dom,dc=$Ext" 

foreach ($User in $Users) {
    Add-ADGroupMember -Identity "G_Services_Operationnels" -Members $User
}

$Users = Get-ADUser -Filter * -SearchBase "OU=Laboratoire,OU=Croix-Rousse,OU=Sites,dc=$Dom,dc=$Ext" 

foreach ($User in $Users) {
    Add-ADGroupMember -Identity "G_Laboratoire" -Members $User
}

$Users = Get-ADUser -Filter * -SearchBase "OU=Pharmacie,OU=Croix-Rousse,OU=Sites,dc=$Dom,dc=$Ext" 

foreach ($User in $Users) {
    Add-ADGroupMember -Identity "G_Pharmacie" -Members $User
}

$Users = Get-ADUser -Filter * -SearchBase "OU=Radiologie,OU=Croix-Rousse,OU=Sites,dc=$Dom,dc=$Ext" 

foreach ($User in $Users) {
    Add-ADGroupMember -Identity "G_Radiologie" -Members $User
}

$Users = Get-ADUser -Filter * -SearchBase "OU=Recherche et Developpement,OU=Croix-Rousse,OU=Sites,dc=$Dom,dc=$Ext" 

foreach ($User in $Users) {
    Add-ADGroupMember -Identity "G_Recherche_et_Developpement" -Members $User
}

$Users = Get-ADUser -Filter * -SearchBase "OU=Ressources Humaines,OU=Croix-Rousse,OU=Sites,dc=$Dom,dc=$Ext" 

foreach ($User in $Users) {
    Add-ADGroupMember -Identity "G_Ressources_Humaines" -Members $User
}
