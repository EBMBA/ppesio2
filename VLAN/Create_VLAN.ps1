Import-module -Name 'C:\Program Files\Intel\Wired Networking\IntelNetCmdlets\IntelNetCmdlets'
$IntelAdaptater = Get-IntelNetAdapter -Name "Intel*"

$networkVLANs=(
    #@{"VLAN"="1";"Name"="AdministrationSwitch"},
    @{"VLAN"="1100";"Name"="Public"},
    @{"VLAN"="1101";"Name"="Services_Operationnels"},
    @{"VLAN"="1102";"Name"="Laboratoire"},
    @{"VLAN"="1103";"Name"="R_et_D"},
    @{"VLAN"="1104";"Name"="Radiologie"},
    @{"VLAN"="1105";"Name"="Pharmacie"},
    @{"VLAN"="1106";"Name"="Administration"},
    @{"VLAN"="1107";"Name"="Accueil"},
    @{"VLAN"="1108";"Name"="Informatique"},
    @{"VLAN"="1109";"Name"="Direction"},
    @{"VLAN"="1160";"Name"="Ressources Humaines"},
    @{"VLAN"="1161";"Name"="Serveur"},
    @{"VLAN"="1162";"Name"="DMZ"},
    @{"VLAN"="1163";"Name"="Covid19"},
    @{"VLAN"="1164";"Name"="Natif"}
)

foreach ($network in $networkVLANs) {
    Add-IntelNetVLAN -ParentName  $IntelAdaptater.Name -VLANID $network["VLAN"] 
    Set-IntelNetVLAN -ParentName $IntelAdaptater.Name -VLANID $network["VLAN"] -NewVLANName "$($network["VLAN"]) - $($network["Name"])"
    $Vlan = $network["VLAN"]
    $Newname = $network["Name"]
    $Name = $(Get-NetAdapter | where {$_.InterfaceDescription -like "*$Vlan*"}).Name
    Rename-NetAdapter -Name $Name -NewName $Newname
}
