### Enter these commands on Exchange Management Shell ###

# Take all ADDS's accounts which aren't system's accounts and enable e-mail account 
Get-User -RecipientTypeDetails User -Filter "UserPrincipalName -ne `$null" -ResultSize unlimited | Enable-Mailbox

# Take all ADDS's groups and enable distribution groups 
#Get-ADGroup -Filter * -SearchBase "OU=Groupes,OU=Sites,DC=CHL,DC=loc" | Enable-DistributionGroup

# Show all e-mail accounts
Get-Mailbox | Format-List Name,DisplayName,Alias,PrimarySmtpAddress,Database
