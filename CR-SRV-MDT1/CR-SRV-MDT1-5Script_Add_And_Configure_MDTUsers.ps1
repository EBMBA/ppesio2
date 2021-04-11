# Requirement : RSAT-ADDS, MDT, ADK and ADK WinPE Addon install | Deployment Share create 
$DNSRoot = (Get-ADDomain).DNSRoot

# Install NTFSSecurity module need the Internet 
Install-Module NTFSSecurity 

# Create MDT_BA and MDT_JD change user principal name 
New-ADUser -Name MDT_BA -UserPrincipalName "MDT_BA@$DNSRoot" -Description "MDT Build Account" -AccountPassword (ConvertTo-SecureString "123+Aze" -AsPlainText -Force) -ChangePasswordAtLogon $false -Enabled $true
New-ADUser -Name MDT_JD -UserPrincipalName "MDT_JD@$DNSRoot" -Description "MDT Join Domain" -AccountPassword (ConvertTo-SecureString "123+Aze" -AsPlainText -Force) -ChangePasswordAtLogon $false -Enabled $true

Set-ADUser -Identity MDT_BA -PasswordNeverExpires $true
Set-ADUser -Identity MDT_JD -PasswordNeverExpires $true

# Prepare variable to apply permissions 
$Sites = ('Croix-Rousse')
$Services = ('Informatique','Medecins','Infirmieres','Aides-Soignantes','Direction','Laboratoire','Recherche et Developpement','Radiologie','Pharmacie','Administration','Accueil','Ressources Humaines', "Serveurs")
$Machines = ('Ordinateurs Fixes', 'Ordinateurs Portables')
$SearchBase=(Get-ADDomain).DistinguishedName
[array]$OrganizationalUnitDN = New-Object System.Collections.ArrayList
foreach ($Site in $Sites){
    foreach ($Service in $Services){
        if ($Service -eq "Serveurs") {
            $MachineObjectOU =$((Get-ADOrganizationalUnit -filter {Name -like $Service} -SearchBase $SearchBase).DistinguishedName)  
            $OrganizationalUnitDN += ($MachineObjectOU) 
        }
        else {
            foreach ($Machine in $Machines) {
                $MachineObjectOU ="OU="+ $Machine+ ",OU=Materiels," + $((Get-ADOrganizationalUnit -filter {Name -like $Service} -SearchBase $SearchBase).DistinguishedName)
                $OrganizationalUnitDN += ($MachineObjectOU)
            }   
        }
    }
}
$UserAccount = Get-ADUser -Identity MDT_JD -properties UserPrincipalName

foreach ($OrganizationalUnitDNItem in $OrganizationalUnitDN) {
    # Create child object and delete a child object for computers | /I:T : This object and sub objects
    dsacls.exe $OrganizationalUnitDNItem /G $UserAccount":CCDC;Computer" /I:T | Out-Null
    
    # List the children of an object for computers | /I:S : Sub objects only
    dsacls.exe $OrganizationalUnitDNItem /G $UserAccount":LC;;Computer" /I:S | Out-Null

    # Read security information for computers | /I:S : Sub objects only
    dsacls.exe $OrganizationalUnitDNItem /G $UserAccount":RC;;Computer" /I:S | Out-Null

    # Change security information for computers | /I:S : Sub objects only
    dsacls.exe $OrganizationalUnitDNItem /G $UserAccount":WD;;Computer" /I:S  | Out-Null

    # Write property for computers | /I:S : Sub objects only
    dsacls.exe $OrganizationalUnitDNItem /G $UserAccount":WP;;Computer" /I:S  | Out-Null

    # Read property for computers | /I:S : Sub objects only
    dsacls.exe $OrganizationalUnitDNItem /G $UserAccount":RP;;Computer" /I:S | Out-Null
    
    # Control access right to reset password of computers | /I:S : Sub objects only
    dsacls.exe $OrganizationalUnitDNItem /G $UserAccount":CA;Reset Password;Computer" /I:S | Out-Null

    # Control access right to change password of computers | /I:S : Sub objects only
    dsacls.exe $OrganizationalUnitDNItem /G $UserAccount":CA;Change Password;Computer" /I:S | Out-Null

    # Write and validated write to service principal name for computers | /I:S : Sub objects only
    dsacls.exe $OrganizationalUnitDNItem /G $UserAccount":WS;Validated write to service principal name;Computer" /I:S | Out-Null

    # Write and validated write to DNS host name for computers
    dsacls.exe $OrganizationalUnitDNItem /G $UserAccount":WS;Validated write to DNS host name;Computer" /I:S | Out-Null

    # Diplay the security on the object
    dsacls.exe $OrganizationalUnitDNItem

}

# Permissions SMB on DeploymentShare change account name and repertory name
grant-smbshareaccess -Name DeploymentShare$ -AccountName "$($DNSRoot.Substring(0,$($DNSRoot.IndexOf("."))))\MDT_BA" -AccessRight Full -force

# Permissions NTFS on Deployment Share change account name and repertory name
Add-NTFSAccess –Path M:\DeploymentShare –Account "$($DNSRoot.Substring(0,$($DNSRoot.IndexOf("."))))\MDT_BA" –AccessRights FullControl

# If you want to check NTFS permissions :
# Get-NTFSAccess –Path $RessourcePath | Out-GridView

