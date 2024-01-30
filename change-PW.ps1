Function Check-RunAsAdministrator()
{
  #Get current user context
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  #Check user is running the script is member of Administrator Group
  if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
       Write-host "Script is running with Administrator privileges!"
  }
  else
    {
       #Create a new Elevated process to Start PowerShell
       $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
 
       # Specify the current script path and name as a parameter
       $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
 
       #Set the Process to elevated
       $ElevatedProcess.Verb = "runas"
 
       #Start the new elevated process
       [System.Diagnostics.Process]::Start($ElevatedProcess)
 
       #Exit from the current, unelevated, process
       Exit
 
    }
}
 
#Check Script is running with Elevated Privileges
Check-RunAsAdministrator

$OUmatch = "CertII","CertII_VETiS","CertIII","CertIV_Networking","CertIV_WebDevelopment","Diploma"

while ($true) {
    $OUprompt = Read-Host -Prompt "Please enter the following OU to change all users in OU
- CertII
- CertII_VETiS
- CertIII
- CertIV_Networking
- CertIV_WebDevelopment
- Diploma
Type 'quit' to cancel"
    if ( $OUprompt -match 'quit') {
    Exit
    }
    elseif ( $OUprompt -match 'Lecturers' ) {
    Write-Host "
This OU is not allowed!
" -ForegroundColor red -BackgroundColor white
    }
    elseif ( $OUprompt -in $OUmatch) {
    break
    }
    else {
    Write-Host "Invalid option" -ForegroundColor red -BackgroundColor white
    }
}

$Passwordprompt = Read-Host -Prompt "Enter desired Password for affect users in $OUprompt"
 
# Set the distinguished name of the OU
$ouPath = "OU=" + $OUprompt + ",OU=Users,OU=Bunbury,OU=FORCE,DC=FORCE,DC=INTERNAL"  # Replace with your OU's distinguished name

# Get all users in the specified OU
$users = Get-ADUser -Filter * -SearchBase "$ouPath"

# Loop through each user and set a new password
foreach ($user in $users) {
    $newPassword = ConvertTo-SecureString -String $Passwordprompt -AsPlainText -Force  # Replace "NewPassword123!" with the desired password
    Set-ADAccountPassword -Identity $user -NewPassword $newPassword -Reset
}
Read-Host -Prompt "Script completed, please check for errors

Press any key to close window"