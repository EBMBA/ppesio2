$NameServer = "CR-SRV-MDT1"
$InstallDirectory = "M:\RemoteInstall"

Install-WindowsFeature -Name WDS -IncludeManagementTools
WDSUTIL /Verbose /Progress /Initialize-Server /Server:$NameServer /RemInst:$InstallDirectory
WDSUTIL /Set-Server /AnswerClients:All