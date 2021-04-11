Install-Module PSWriteWord 
Import-Module PSWriteWord

function New-Password
{

   $Alphabets = 'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z'
    $numbers = 0..9
    $specialCharacters = '~,!,@,#,$,%,^,&,*,(,),>,<,?,\,/,_,-,=,+'
    $array = @()
    $array += $Alphabets.Split(',') | Get-Random -Count 4
    $array[0] = $array[0].ToUpper()
    $array[-1] = $array[-1].ToUpper()
    $array += $numbers | Get-Random -Count 3
    $array += $specialCharacters.Split(',') | Get-Random -Count 3
    ($array | Get-Random -Count $array.Count) -join ""
}

function New-RandomUser {
    <#
        .SYNOPSIS
            Generate random user data from Https://randomuser.me/.
        .DESCRIPTION
            This function uses the free API for generating random user data from https://randomuser.me/
        .EXAMPLE
            Get-RandomUser 10
        .EXAMPLE
            Get-RandomUser -Amount 25 -Nationality us,gb 
        .LINK
            https://randomuser.me/
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateRange(1,500)]
        [int] $Amount,

        [Parameter()]
        [ValidateSet('Male','Female')]
        [string] $Gender,

        # Supported nationalities: AU, BR, CA, CH, DE, DK, ES, FI, FR, GB, IE, IR, NL, NZ, TR, US
        [Parameter()]
        [string[]] $Nationality,


        [Parameter()]
        [ValidateSet('json','csv','xml')]
        [string] $Format = 'json',

        # Fields to include in the results.
        # Supported values: gender, name, location, email, login, registered, dob, phone, cell, id, picture, nat
        [Parameter()]
        [string[]] $IncludeFields,

        # Fields to exclude from the the results.
        # Supported values: gender, name, location, email, login, registered, dob, phone, cell, id, picture, nat
        [Parameter()]
        [string[]] $ExcludeFields
    )

    $rootUrl = "http://api.randomuser.me/?format=$($Format)"

    if ($Amount) {
        $rootUrl += "&results=$($Amount)"
    }

    if ($Gender) {
        $rootUrl += "&gender=$($Gender)"
    }


    if ($Nationality) {
        $rootUrl += "&nat=$($Nationality -join ',')"
    }

    if ($IncludeFields) {
        $rootUrl += "&inc=$($IncludeFields -join ',')"
    }

    if ($ExcludeFields) {
        $rootUrl += "&exc=$($ExcludeFields -join ',')"
    }
    
    Invoke-RestMethod -Uri $rootUrl
}

#region declarations des variables
# Recuperations des informations du domaine AD
$fqdn = Get-ADDomain
$fulldomain = $fqdn.DNSRoot
$domain = $fulldomain.split(".")
$Dom = $domain[0]
$Ext = $domain[1]

# Informations des Sites et Services
$sites=('Croix-Rousse')
$services=('Informatique','Services Operationnels','Direction','Laboratoire','Recherche et Developpement','Radiologie','Pharmacie','Administration','Accueil','Ressources Humaines','Serveurs')
$sousServices=('Medecins','Infirmieres','Aides-Soignantes')
$materiels=('Ordinateurs Fixes','Ordinateurs Portables','Imprimantes')
$FirstOU ="Sites"

#endregions
$sw = [Diagnostics.Stopwatch]::StartNew()

New-ADOrganizationalUnit -Name $FirstOU -Description $FirstOU  -Path "DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false

foreach ($S in $sites) {
    New-ADOrganizationalUnit -Name $S -Description "$S"  -Path "OU=$FirstOU,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false

    foreach ($Serv in $services) {
        New-ADOrganizationalUnit -Name $Serv -Description "$S $Serv"  -Path "OU=$S,OU=$FirstOU,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false

        if ($Serv -eq "Services Operationnels") {
            foreach ($sousServ in $sousservices) {
                New-ADOrganizationalUnit -Name $sousServ -Description "$S $Serv $sousServ"  -Path "OU=$Serv,OU=$S,OU=$FirstOU,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
                New-ADOrganizationalUnit -Name "Materiels" -Description "$S $Serv Materiels"  -Path "OU=$sousServ,OU=$Serv,OU=$S,OU=$FirstOU,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
                foreach ($Materiel in $materiels) {
                    New-ADOrganizationalUnit -Name $Materiel -Description "$S $Serv $Materiel"  -Path "OU=Materiels,OU=$sousServ,OU=$Serv,OU=$S,OU=$FirstOU,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
                    
                }

                switch ($sousServ) {
                    'Medecins' { 
                        $Employees = New-RandomUser -Amount 10 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results

                        foreach ($user in $Employees) 
                        {
                            #New Password
                            $userPassword = New-Password

                            $newUserProperties = @{
                                Name = "$($user.name.first) $($user.name.last)"
                                City = "$S"
                                GivenName = $user.name.first
                                Surname = $user.name.last
                                Path = "OU=$sousServ,OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
                                title = "$sousServ"
                                department="$Serv"
                                OfficePhone = $user.phone
                                MobilePhone = $user.cell
                                Company="$Dom"
                                EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
                                AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
                                SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
                                UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
                                Enabled = $true
                            }
                            
                             if(!(Test-Path -Path "c:\$S\$Serv\$sousServ\Employes"))
                            {
                                New-Item -Path "c:\$S\$Serv\$sousServ\Employes" -ItemType Directory | Out-Null
                            }
                            else
                            {
                                #"The directory exist" 
                            }


                            $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

                            $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
               
                            $FilePathInvoice  = "c:\$S\$Serv\$sousServ\Employes\$($user.name.last) $($user.name.first).docx"
                            Add-WordText -WordDocument $WordDocument -Text 'Creation de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


                            Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
                            -FontSize 12, 13 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingBefore 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text 'Login : ', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Mot de passe : ',"$userPassword" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie : ',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingAfter 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
                            -FontSize 12 `
                            -Supress $True

                            Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'

                            New-ADUser @newUserProperties
                        }

                     }
                    
                     'Infirmieres'{
                        $Employees = New-RandomUser -Amount 20 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results

                        foreach ($user in $Employees) 
                        {
                            #New Password
                            $userPassword = New-Password

                            $newUserProperties = @{
                                Name = "$($user.name.first) $($user.name.last)"
                                City = "$S"
                                GivenName = $user.name.first
                                Surname = $user.name.last
                                Path = "OU=$sousServ,OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
                                title = "$sousServ"
                                department="$Serv"
                                OfficePhone = $user.phone
                                MobilePhone = $user.cell
                                Company="$Dom"
                                EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
                                AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
                                SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
                                UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
                                Enabled = $true
                            }
                            
                             if(!(Test-Path -Path "c:\$S\$Serv\$sousServ\Employes"))
                            {
                                New-Item -Path "c:\$S\$Serv\$sousServ\Employes" -ItemType Directory | Out-Null
                            }
                            else
                            {
                                #"The directory exist" 
                            }


                            $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

                            $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
               
                            $FilePathInvoice  = "c:\$S\$Serv\$sousServ\Employes\$($user.name.last) $($user.name.first).docx"
                            Add-WordText -WordDocument $WordDocument -Text 'Creation de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


                            Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
                            -FontSize 12, 13 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingBefore 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text 'Login : ', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Mot de passe : ',"$userPassword" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie : ',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingAfter 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
                            -FontSize 12 `
                            -Supress $True

                            Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'

                            New-ADUser @newUserProperties
                        }
                     }

                     'Aides-Soignantes'
                     {
                        $Employees = New-RandomUser -Amount 20 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results

                        foreach ($user in $Employees) 
                        {
                            #New Password
                            $userPassword = New-Password

                            $newUserProperties = @{
                                Name = "$($user.name.first) $($user.name.last)"
                                City = "$S"
                                GivenName = $user.name.first
                                Surname = $user.name.last
                                Path = "OU=$sousServ,OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
                                title = "$sousServ"
                                department="$Serv"
                                OfficePhone = $user.phone
                                MobilePhone = $user.cell
                                Company="$Dom"
                                EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
                                AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
                                SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
                                UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
                                Enabled = $true
                            }
                            
                             if(!(Test-Path -Path "c:\$S\$Serv\$sousServ\Employes"))
                            {
                                New-Item -Path "c:\$S\$Serv\$sousServ\Employes" -ItemType Directory | Out-Null
                            }
                            else
                            {
                                #"The directory exist" 
                            }


                            $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

                            $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
               
                            $FilePathInvoice  = "c:\$S\$Serv\$sousServ\Employes\$($user.name.last) $($user.name.first).docx"
                            Add-WordText -WordDocument $WordDocument -Text 'Creation de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


                            Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
                            -FontSize 12, 13 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingBefore 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text 'Login : ', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Mot de passe : ',"$userPassword" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie : ',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingAfter 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
                            -FontSize 12 `
                            -Supress $True

                            Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'

                            New-ADUser @newUserProperties
                        }
                     }
                    Default {}
                }
                
                
            }


        }

        else {
            New-ADOrganizationalUnit -Name "Materiels" -Description "$S $Serv Materiels"  -Path "OU=$Serv,OU=$S,OU=$FirstOU,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
            foreach ($Materiel in $materiels) {
                New-ADOrganizationalUnit -Name $Materiel -Description "$S $Serv $Materiel"  -Path "OU=Materiels,OU=$Serv,OU=$S,OU=$FirstOU,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
            }

            switch ($Serv) {
                'Laboratoire'{
                    $Employees = New-RandomUser -Amount 25 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results

                        foreach ($user in $Employees) 
                        {
                            #New Password
                            $userPassword = New-Password

                            $newUserProperties = @{
                                Name = "$($user.name.first) $($user.name.last)"
                                City = "$S"
                                GivenName = $user.name.first
                                Surname = $user.name.last
                                Path = "OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
                                title = "Employé $Serv"
                                department="$Serv"
                                OfficePhone = $user.phone
                                MobilePhone = $user.cell
                                Company="$Dom"
                                EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
                                AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
                                SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
                                UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
                                Enabled = $true
                            }
                            
                             if(!(Test-Path -Path "c:\$S\$Serv\Employes"))
                            {
                                New-Item -Path "c:\$S\$Serv\Employes" -ItemType Directory | Out-Null
                            }
                            else
                            {
                                #"The directory exist" 
                            }


                            $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

                            $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
               
                            $FilePathInvoice  = "c:\$S\$Serv\Employes\$($user.name.last) $($user.name.first).docx"
                            Add-WordText -WordDocument $WordDocument -Text 'Creation de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


                            Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
                            -FontSize 12, 13 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingBefore 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text 'Login : ', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Mot de passe : ',"$userPassword" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie : ',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingAfter 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
                            -FontSize 12 `
                            -Supress $True

                            Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'

                            New-ADUser @newUserProperties
                            
                        }
                }
                
                'Recherche et Developpement'{
                    $Employees = New-RandomUser -Amount 20 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results

                        foreach ($user in $Employees) 
                        {
                            #New Password
                            $userPassword = New-Password

                            $newUserProperties = @{
                                Name = "$($user.name.first) $($user.name.last)"
                                City = "$S"
                                GivenName = $user.name.first
                                Surname = $user.name.last
                                Path = "OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
                                title = "Employé $Serv"
                                department="$Serv"
                                OfficePhone = $user.phone
                                MobilePhone = $user.cell
                                Company="$Dom"
                                EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
                                AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
                                SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
                                UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
                                Enabled = $true
                            }
                            
                             if(!(Test-Path -Path "c:\$S\$Serv\Employes"))
                            {
                                New-Item -Path "c:\$S\$Serv\Employes" -ItemType Directory | Out-Null
                            }
                            else
                            {
                                #"The directory exist" 
                            }


                            $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

                            $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
               
                            $FilePathInvoice  = "c:\$S\$Serv\Employes\$($user.name.last) $($user.name.first).docx"
                            Add-WordText -WordDocument $WordDocument -Text 'Creation de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


                            Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
                            -FontSize 12, 13 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingBefore 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text 'Login : ', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Mot de passe : ',"$userPassword" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie : ',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingAfter 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
                            -FontSize 12 `
                            -Supress $True

                            Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'

                            New-ADUser @newUserProperties
                            
                        }
                }

                'Radiologie'{
                    $Employees = New-RandomUser -Amount 20 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results

                        foreach ($user in $Employees) 
                        {
                            #New Password
                            $userPassword = New-Password

                            $newUserProperties = @{
                                Name = "$($user.name.first) $($user.name.last)"
                                City = "$S"
                                GivenName = $user.name.first
                                Surname = $user.name.last
                                Path = "OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
                                title = "Employé $Serv"
                                department="$Serv"
                                OfficePhone = $user.phone
                                MobilePhone = $user.cell
                                Company="$Dom"
                                EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
                                AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
                                SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
                                UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
                                Enabled = $true
                            }
                            
                             if(!(Test-Path -Path "c:\$S\$Serv\Employes"))
                            {
                                New-Item -Path "c:\$S\$Serv\Employes" -ItemType Directory | Out-Null
                            }
                            else
                            {
                                #"The directory exist" 
                            }


                            $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

                            $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
               
                            $FilePathInvoice  = "c:\$S\$Serv\Employes\$($user.name.last) $($user.name.first).docx"
                            Add-WordText -WordDocument $WordDocument -Text 'Creation de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


                            Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
                            -FontSize 12, 13 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingBefore 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text 'Login : ', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Mot de passe : ',"$userPassword" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie : ',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingAfter 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
                            -FontSize 12 `
                            -Supress $True

                            Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'

                            New-ADUser @newUserProperties
                            
                        }
                }

                'Pharmacie'{
                    $Employees = New-RandomUser -Amount 20 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results

                        foreach ($user in $Employees) 
                        {
                            #New Password
                            $userPassword = New-Password

                            $newUserProperties = @{
                                Name = "$($user.name.first) $($user.name.last)"
                                City = "$S"
                                GivenName = $user.name.first
                                Surname = $user.name.last
                                Path = "OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
                                title = "Employé $Serv"
                                department="$Serv"
                                OfficePhone = $user.phone
                                MobilePhone = $user.cell
                                Company="$Dom"
                                EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
                                AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
                                SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
                                UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
                                Enabled = $true
                            }
                            
                             if(!(Test-Path -Path "c:\$S\$Serv\Employes"))
                            {
                                New-Item -Path "c:\$S\$Serv\Employes" -ItemType Directory | Out-Null
                            }
                            else
                            {
                                #"The directory exist" 
                            }


                            $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

                            $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
               
                            $FilePathInvoice  = "c:\$S\$Serv\Employes\$($user.name.last) $($user.name.first).docx"
                            Add-WordText -WordDocument $WordDocument -Text 'Creation de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


                            Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
                            -FontSize 12, 13 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingBefore 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text 'Login : ', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Mot de passe : ',"$userPassword" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie : ',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingAfter 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
                            -FontSize 12 `
                            -Supress $True

                            Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'

                            New-ADUser @newUserProperties
                            
                        }

                }

                'Administration'{
                    $Employees = New-RandomUser -Amount 30 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results

                        foreach ($user in $Employees) 
                        {
                            #New Password
                            $userPassword = New-Password

                            $newUserProperties = @{
                                Name = "$($user.name.first) $($user.name.last)"
                                City = "$S"
                                GivenName = $user.name.first
                                Surname = $user.name.last
                                Path = "OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
                                title = "Employé $Serv"
                                department="$Serv"
                                OfficePhone = $user.phone
                                MobilePhone = $user.cell
                                Company="$Dom"
                                EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
                                AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
                                SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
                                UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
                                Enabled = $true
                            }
                            
                             if(!(Test-Path -Path "c:\$S\$Serv\Employes"))
                            {
                                New-Item -Path "c:\$S\$Serv\Employes" -ItemType Directory | Out-Null
                            }
                            else
                            {
                                #"The directory exist" 
                            }


                            $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

                            $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
               
                            $FilePathInvoice  = "c:\$S\$Serv\Employes\$($user.name.last) $($user.name.first).docx"
                            Add-WordText -WordDocument $WordDocument -Text 'Creation de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


                            Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
                            -FontSize 12, 13 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingBefore 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text 'Login : ', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Mot de passe : ',"$userPassword" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie : ',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingAfter 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
                            -FontSize 12 `
                            -Supress $True

                            Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'

                            New-ADUser @newUserProperties
                            
                        }

                        
                }

                'Accueil'{
                    $Employees = New-RandomUser -Amount 20 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results

                        foreach ($user in $Employees) 
                        {
                            #New Password
                            $userPassword = New-Password

                            $newUserProperties = @{
                                Name = "$($user.name.first) $($user.name.last)"
                                City = "$S"
                                GivenName = $user.name.first
                                Surname = $user.name.last
                                Path = "OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
                                title = "Employé $Serv"
                                department="$Serv"
                                OfficePhone = $user.phone
                                MobilePhone = $user.cell
                                Company="$Dom"
                                EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
                                AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
                                SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
                                UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
                                Enabled = $true
                            }
                            
                             if(!(Test-Path -Path "c:\$S\$Serv\Employes"))
                            {
                                New-Item -Path "c:\$S\$Serv\Employes" -ItemType Directory | Out-Null
                            }
                            else
                            {
                                #"The directory exist" 
                            }


                            $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

                            $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
               
                            $FilePathInvoice  = "c:\$S\$Serv\Employes\$($user.name.last) $($user.name.first).docx"
                            Add-WordText -WordDocument $WordDocument -Text 'Creation de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


                            Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
                            -FontSize 12, 13 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingBefore 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text 'Login : ', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Mot de passe : ',"$userPassword" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie : ',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingAfter 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
                            -FontSize 12 `
                            -Supress $True

                            Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'

                            New-ADUser @newUserProperties
                            
                        }

                }

                'Informatique'{
                    $Employees = New-RandomUser -Amount 15 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results

                        foreach ($user in $Employees) 
                        {
                            #New Password
                            $userPassword = New-Password

                            $newUserProperties = @{
                                Name = "$($user.name.first) $($user.name.last)"
                                City = "$S"
                                GivenName = $user.name.first
                                Surname = $user.name.last
                                Path = "OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
                                title = "Employé $Serv"
                                department="$Serv"
                                OfficePhone = $user.phone
                                MobilePhone = $user.cell
                                Company="$Dom"
                                EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
                                AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
                                SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
                                UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
                                Enabled = $true
                            }
                            
                             if(!(Test-Path -Path "c:\$S\$Serv\Employes"))
                            {
                                New-Item -Path "c:\$S\$Serv\Employes" -ItemType Directory | Out-Null
                            }
                            else
                            {
                                #"The directory exist" 
                            }


                            $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

                            $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
               
                            $FilePathInvoice  = "c:\$S\$Serv\Employes\$($user.name.last) $($user.name.first).docx"
                            Add-WordText -WordDocument $WordDocument -Text 'Creation de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


                            Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
                            -FontSize 12, 13 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingBefore 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text 'Login : ', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Mot de passe : ',"$userPassword" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie : ',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingAfter 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
                            -FontSize 12 `
                            -Supress $True

                            Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'

                            New-ADUser @newUserProperties
                            
                        }

                }

                'Ressources Humaines'{
                    $Employees = New-RandomUser -Amount 16 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results

                        foreach ($user in $Employees) 
                        {
                            #New Password
                            $userPassword = New-Password

                            $newUserProperties = @{
                                Name = "$($user.name.first) $($user.name.last)"
                                City = "$S"
                                GivenName = $user.name.first
                                Surname = $user.name.last
                                Path = "OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
                                title = "Employé $Serv"
                                department="$Serv"
                                OfficePhone = $user.phone
                                MobilePhone = $user.cell
                                Company="$Dom"
                                EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
                                AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
                                SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
                                UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
                                Enabled = $true
                            }
                            
                             if(!(Test-Path -Path "c:\$S\$Serv\Employes"))
                            {
                                New-Item -Path "c:\$S\$Serv\Employes" -ItemType Directory | Out-Null
                            }
                            else
                            {
                                #"The directory exist" 
                            }


                            $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

                            $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
               
                            $FilePathInvoice  = "c:\$S\$Serv\Employes\$($user.name.last) $($user.name.first).docx"
                            Add-WordText -WordDocument $WordDocument -Text 'Creation de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


                            Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
                            -FontSize 12, 13 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingBefore 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text 'Login : ', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Mot de passe : ',"$userPassword" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie : ',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingAfter 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
                            -FontSize 12 `
                            -Supress $True

                            Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'

                            New-ADUser @newUserProperties
                            
                        }

                }

                'Direction'{
                    $Employees = New-RandomUser -Amount 18 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results

                        foreach ($user in $Employees) 
                        {
                            #New Password
                            $userPassword = New-Password

                            $newUserProperties = @{
                                Name = "$($user.name.first) $($user.name.last)"
                                City = "$S"
                                GivenName = $user.name.first
                                Surname = $user.name.last
                                Path = "OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
                                title = "Employé $Serv"
                                department="$Serv"
                                OfficePhone = $user.phone
                                MobilePhone = $user.cell
                                Company="$Dom"
                                EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
                                AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
                                SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
                                UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
                                Enabled = $true
                            }
                            
                             if(!(Test-Path -Path "c:\$S\$Serv\Employes"))
                            {
                                New-Item -Path "c:\$S\$Serv\Employes" -ItemType Directory | Out-Null
                            }
                            else
                            {
                                #"The directory exist" 
                            }


                            $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

                            $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
               
                            $FilePathInvoice  = "c:\$S\$Serv\Employes\$($user.name.last) $($user.name.first).docx"
                            Add-WordText -WordDocument $WordDocument -Text 'Creation de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


                            Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
                            -FontSize 12, 13 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingBefore 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text 'Login : ', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Mot de passe : ',"$userPassword" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -Supress $True

                            Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie : ',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
                            -FontSize 12, 10 `
                            -Color  Black, Blue `
                            -Bold  $false, $true `
                            -SpacingAfter 15 `
                            -Supress $True
        
                            Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
                            -FontSize 12 `
                            -Supress $True

                            Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'

                            New-ADUser @newUserProperties
                            
                        }

                }
                Default {}
            }
        }
        
    }
}

Write-Host "Creations des OU pour les groupes" -ForegroundColor Magenta
Write-Host ""

New-ADOrganizationalUnit -Name Groupes -Description "Groupes du Domaine" -Path "OU=Sites,DC=$Dom,DC=$Ext" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name Globaux -Description "Groupes Globaux" -Path "OU=Groupes,OU=Sites,DC=$Dom,DC=$Ext" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Domaines Locaux" -Description "Groupes de Domaines Locaux"  -Path "OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false

Write-Host "Creations des groupes Globaux et Groupes de Domaines Locaux" -ForegroundColor Magenta
Write-Host ""
 
foreach ($item in $services) {
    if ($item -eq 'Services Operationnels') {
        foreach ($sousServ in $sousServices) {
            $i=$item.Replace(" ","_")
            Write-Host "Creation des groupes Globaux G_$I , G_Employes_$I et G_Responsable_$I le service $i" -ForegroundColor Magenta
            Write-Host ""

            New-ADGroup -Name "G_$i" -DisplayName "G_$i" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Global $i"
            New-ADGroup -Name "G_Employes_$i" -DisplayName "G_Employes_$i" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Global Employes $i"
            New-ADGroup -Name "G_Responsables_$i" -DisplayName "G_Responsables_$i" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Global Responsables $i"
  
            Write-Host "Creation des groupes de Domaine Locaux DL_$i`_L , DL_$i`_LM DL_$i`_CT pour le service $i" -ForegroundColor Magenta
            Write-Host ""

            New-ADGroup -Name  "DL_$i`_L" -DisplayName  "DL_$i`_L" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT"  -Description "Groupe Domaine Locaux $i Lecture"
            New-ADGroup -Name  "DL_$i`_LM" -DisplayName  "DL_$i`_LM" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT"  -Description "Groupe Domaine Locaux $i Lecture et Modification"
            New-ADGroup -Name  "DL_$i`_CT" -DisplayName  "DL_$i`_CT" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Domaine Locaux $i Controle Totale"
        }
    }

    else {
        $i=$item.Replace(" ","_")

        Write-Host "Creation des groupes Globaux G_$I , G_Employes_$I et G_Responsable_$I le service $i" -ForegroundColor Magenta
        Write-Host ""
        
        New-ADGroup -Name "G_$i" -DisplayName "G_$i" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Global $i"
        New-ADGroup -Name "G_Employes_$i" -DisplayName "G_Employes_$i" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Global Employes $i"
        New-ADGroup -Name "G_Responsables_$i" -DisplayName "G_Responsables_$i" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Global Responsables $i"
  
        Write-Host "Creation des groupes de Domaine Locaux DL_$i`_L , DL_$i`_LM DL_$i`_CT pour le service $i" -ForegroundColor Magenta
        Write-Host ""

        New-ADGroup -Name  "DL_$i`_L" -DisplayName  "DL_$i`_L" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT"  -Description "Groupe Domaine Locaux $i Lecture"
        New-ADGroup -Name  "DL_$i`_LM" -DisplayName  "DL_$i`_LM" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT"  -Description "Groupe Domaine Locaux $i Lecture et Modification"
        New-ADGroup -Name  "DL_$i`_CT" -DisplayName  "DL_$i`_CT" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Domaine Locaux $i Controle Totale"
        

    }
}

New-ADGroup -Name "G_Responsables" -DisplayName "G_Responsables" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Responsable"
New-ADGroup -Name "G_Employes" -DisplayName "G_Employes" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Employes"

Write-Host "Creation des groupes de Domaine Locaux DL_Accès Commun_L , DL_Accès Commun_LM DL_Accès Commun_CT " -ForegroundColor Magenta
Write-Host ""

New-ADGroup -Name  "DL_Acces_Commun_L" -DisplayName  "DL_Acces_Commun_L" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT"  -Description "Groupe Domaine Locaux $i Lecture"
New-ADGroup -Name  "DL_Acces_Commun_LM" -DisplayName  "DL_Acces_Commun_LM" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT"  -Description "Groupe Domaine Locaux $i Lecture et Modification"
New-ADGroup -Name  "DL_Acces_Commun_CT" -DisplayName  "DL_Acces_Commun_CT" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Domaine Locaux $i Controle Totale"


$User = $(Get-ADUser -Filter * -SearchBase "OU=Sites,dc=$Dom,dc=$Ext").count
$Group = $(Get-ADGroup -Filter * -SearchBase "OU=Sites,dc=$Dom,dc=$Ext").count
$OU = $(Get-ADOrganizationalUnit -Filter * -SearchBase "OU=Sites,dc=$Dom,dc=$Ext").count
$Object = $(Get-ADObject -Filter * -SearchBase "OU=Sites,dc=$Dom,dc=$Ext").count

Write-Host "Nous avons créer $user Utilisateurs, $Group Groupes Acitve Directory et $OU OU soit $Object Objects. "
$sw.stop
$sw.Elapsed