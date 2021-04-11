$DomainNameDNS = "CHL.loc"
$DomainNameNetbios = "CHL"

$FeatureList = @("RSAT-AD-Tools", "AD-Domain-Services", "DNS")

Foreach($Feature in $FeatureList){

    if(((Get-WindowsFeature -Name $Feature).InstallState)-eq "Available"){

            Write-Output " Feature $Feature will be installed now ! "

                Try{

                        Add-WindowsFeature -Name $Feature -IncludeManagementTools -IncludeAllSubFeature

                        Write-Output  "$Feature : Installation is a success !"

                }Catch{

                        Write-Output "$Feature : Error during installation !"
                }
        } 
} # Foreach($Feature in $FeatureList)


$ForestConfiguration = @{
'-DatabasePath'= 'C:\Windows\NTDS';
'-DomainMode' = 'Default';
'-DomainName' = $DomainNameDNS;
'-DomainNetbiosName' = $DomainNameNetbios;
'-ForestMode' = 'Default';
'-InstallDns' = $true;
'-LogPath' = 'C:\Windows\NTDS';
'-NoRebootOnCompletion' = $false;
'-SysvolPath' = 'C:\Windows\SYSVOL';
'-Force' = $true;
'-CreateDnsDelegation' = $false }

Import-Module ADDSDeployment
Install-ADDSForest @ForestConfiguration