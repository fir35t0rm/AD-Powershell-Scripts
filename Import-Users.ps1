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

# Path to CSV file
$csvPath = "D:\AD-Import\AD-Import.csv"

# Import CSV and iterate through each row
$users = Import-Csv $csvPath
foreach ($user in $users) {
    # Extract data from CSV
    
    $firstname = $user.givenName
    $lastname = $user.sn
    $passwordprefix = "SRT-" + $user.password
    $password = ConvertTo-SecureString $passwordprefix -AsPlainText -Force
    # SKIP $department = $user.department
    # SKIP $manager = $user.managedby
    # SKIP $phone = $user.telephoneNumber
    $username = $firstname + "." + $lastname
    $name = $firstname + " " + $lastname
    $ouPath = $user.OUPath

    # Create User
    New-ADUser `
    -Name $name `
    -SamAccountName $username `
    -UserPrincipalName "$username@FORCE.internal" `
    -GivenName $firstname `
    -Surname $lastname `
    -DisplayName $name `
    -AccountPassword $password -Enabled $true `
    -Path $ouPath
}

Read-Host -Prompt "Script completed, please check each error of Added AD accounts

Press any key to close window"