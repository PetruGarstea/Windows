$Domain=’’
$Username=’’
$Password=''

$UsernameDomain=$Domain+’\’+$Username

$SecurePassword=Convertto-SecureString –String $Password –AsPlainText –force

$Credentials=New-object System.Management.Automation.PSCredential $UsernameDomain,$SecurePassword

$AllUsers = Get-ADUser -Credential $Credentials -Server heremustbeserver -Filter * -Properties *

$Report = @()

Foreach($User In $AllUsers)

{

    $Username = $User.Name
    $AllGroups = $User.MemberOf
    $PrimaryGroup = $User.PrimaryGroup

    $PrimaryGroupRegex = $PrimaryGroup -replace ',.*','' -match "CN=(?<content>.*)"
    $PrimaryGroup = $matches['content']

    if ($AllGroups)

    {

        Foreach ($Group in $AllGroups)

        {
            
            $GroupRegex = $Group -replace ',.*','' -match "CN=(?<content>.*)"
            $Group = $matches['content']

            $Data = @{            
                        
                        UserName      = $Username
                        GroupName     = $Group
                        PrimaryGroup  = $PrimaryGroup
                    
                     }                    
                    
            $Report += New-Object PSObject -Property $Data      
                          
        }

    }

    Else

        {

            $Data = @{            
                        
                        UserName      = $Username
                        GroupName     = 'NULL'
                        PrimaryGroup  = $PrimaryGroup
                    
                     }

             $Report += New-Object PSObject -Property $Data

        }

}

$Report | export-csv -Path C:\tmp\ad-user-report.csv -NoTypeInformation