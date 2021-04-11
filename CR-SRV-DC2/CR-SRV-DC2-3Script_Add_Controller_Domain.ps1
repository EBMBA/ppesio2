$DomainNameDNS = "CHL.loc"
$DomaineNameNetbios = "CHL"
$FeatureList = @("RSAT-AD-Tools","AD-Domain-Services","DNS")

Foreach($Feature in $FeatureList){

   if(((Get-WindowsFeature -Name $Feature).InstallState)-eq"Available"){

     Write-Output "Feature $Feature will be installed now !"

     Try{

        Add-WindowsFeature -Name $Feature -IncludeManagementTools -IncludeAllSubFeature

        Write-Output "$Feature : Installation is a success !"

     }Catch{

        Write-Output "$Feature : Error during installation !"
     }
   } 
} # Foreach($Feature in $FeatureList)

$DomainConfiguration = @{
    '-DatabasePath'= 'C:\Windows\NTDS';
    '-DomainName' = $DomainNameDNS;
    '-NoGlobalCatalog' = $false;
    '-SiteName' = 'Default-First-Site-Name';
    '-CriticalReplicationOnly' =$false;
    '-InstallDns' = $true;
    '-LogPath' = 'C:\Windows\NTDS';
    '-NoRebootOnCompletion' = $false;
    '-Readonlyreplica' = $true;
    '-ReplicationSourceDC' = 'CR-SRV-DC1.CHL.loc';
    '-SysvolPath' = 'C:\Windows\SYSVOL';
    '-Force' = $true;
    '-CreateDnsDelegation' = $false }

Import-Module ADDSDeployment
Install-ADDSDomainController @DomainConfiguration  -Credential (Get-Credential $DomaineNameNetbios\Administrator)


#
# Windows PowerShell script for AD DS Deployment
#

# Import-Module ADDSDeployment
# Install-ADDSDomainController `
# -AllowPasswordReplicationAccountName @("CHL\Allowed RODC Password Replication Group") `
# -NoGlobalCatalog:$false `
# -Credential (Get-Credential) `
# -CriticalReplicationOnly:$false `
# -DatabasePath "C:\Windows\NTDS" `
# -DenyPasswordReplicationAccountName @("BUILTIN\Administrators", "BUILTIN\Server Operators", "BUILTIN\Backup Operators", "BUILTIN\Account Operators", "CHL\Denied RODC Password Replication Group") `
# -DomainName "CHL.loc" `
# -InstallDns:$true `
# -LogPath "C:\Windows\NTDS" `
# -NoRebootOnCompletion:$false `
# -ReadOnlyReplica:$true `
# -ReplicationSourceDC "CR-SRV-DC1.CHL.loc" `
# -SiteName "Default-First-Site-Name" `
# -SysvolPath "C:\Windows\SYSVOL" `
# -Force:$true

