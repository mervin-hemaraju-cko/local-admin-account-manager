##################################################
################ Helper Functions ################
##################################################

function AddUserToGroup($user, $group) {
    # Add user to the group
    Add-LocalGroupMember -Group $group -Member $user
    
}

function IsUserInGroup($localuser, $users){

    # Iterate through each users
    foreach($User in $users)
    {   
        # Split computer domain and get name only
        $Name = ($User.Name.Split("\"))[1]
        
        # Check if name is present
        if ($Name -eq $localuser) {
            return $true
        }
    }

    # If after iteration name is not present,
    # return false
    return $false
}

function CreateUserIfNotPresent($user, $groups) {

    # Checks if user account is present
    $LocalUser = Get-LocalUser $user -erroraction silentlycontinue

    # If account if not present
    if([string]::IsNullOrWhitespace($LocalUser)){

        # Create a password
        $LocalUserPassword = ConvertTo-SecureString $LocalAdminPassword -AsPlainText -Force

        # Create the user account   
        New-LocalUser $user -Password $LocalUserPassword -FullName "CKO Administrator" -Description "This is the CKO Local Admin User"

        # Add user to all group needed
        foreach($Group in $groups){
            AddUserToGroup $user $Group
        }
    }
}

function IsPasswordCorrect($username) {

    # Get the Computer Name
    $ComputerName = $env:COMPUTERNAME

    # Add the Account Management Assembly
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement

    # Retrieve the Account Management Object
    $AccManagement = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine', $ComputerName)

    # Validate credentials and return boolean
    return $AccManagement.ValidateCredentials($username, $LocalAdminPassword) 
    
}

function ChangePassword($username) {
    # Create a secure password
    $LocalUserPassword = ConvertTo-SecureString $LocalAdminPassword -AsPlainText -Force

    # Change the password
    Get-LocalUser -Name $username | Set-LocalUser -Password $LocalUserPassword
}

###############################################
################ Main Function ################
###############################################
function Main {

    # Local Groups
    $Groups = @("Administrators", "Remote Desktop Users")

    Try {

        # Notify searching started
        Write-Output "Searching for $LocalUserName in local users Database"

        # Checks if the user has already been created
        # If not, creates the user and add to groups
        CreateUserIfNotPresent $LocalUserName $Groups

        # Iterate through list of groups
        foreach($Group in $Groups){
            
            # Get Users of the group
            $UsersFromGroup = Get-LocalGroupMember -Group $Group

            # Checks if user is present or not
            $IsUserInGroup = IsUserInGroup $LocalUserName $UsersFromGroup

            # Check if user is in group
            if(!$IsUserInGroup){

                # If not in group, add it
                AddUserToGroup $LocalUserName $Group
            }
            
        }

        # Check if domain admin password
        if(!(IsPasswordCorrect($LocalUserName))){
            Write-Output "The password for Instance $env:COMPUTERNAME doesn't match the general local admin credentials"
            ChangePassword($LocalUserName)
        }
    }

    Catch {
        "An unspecifed error occured" | Write-Error
        Exit # Stop Powershell! 
    }
    
}


########################################
################ CALLER ################
########################################
Main