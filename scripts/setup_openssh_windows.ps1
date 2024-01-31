########################### SETUP OPENSSH ON WINDOWS ###########################
# Windows builtin OpenSSH does not support SSH signing (requires atleast 8.2)
# This script activates and then upgrades Windows OpenSSH to latest release

Write-Host -ForegroundColor DarkGreen `
    "Executing script for OpenSSH setup on Windows -`n"

Function Write-Info {
    Param (
        [String]$Message,  # Information to write to host display
        [Switch]$N         # Add new-line at the end if included
    )

    If ($N) { Write-Host -ForegroundColor DarkCyan "$Message" }
    Else { Write-Host -NoNewline -ForegroundColor DarkCyan "$Message" }
}

#################### ENABLE BUILTIN SSH ####################

Write-Info " * Enabling Windows builtin OpenSSH Client + Server ... "

Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*' |
    Add-WindowsCapability -Online | Out-Null
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent

Write-Info -N 'Done'

##################### GLOBAL VARIABLES #####################

$ReleaseName = 'OpenSSH-Win64'
$SystemSSH = 'C:\Windows\System32\OpenSSH'
$URL = 'https://github.com/PowerShell/Win32-OpenSSH/releases/latest'

################# DOWNLOAD-EXTRACT RELEASE #################

Write-Info " * Downloading and extracting the latest release on GitHub ... "

# Download the latest release archive from GitHub
$ReleaseNameZip = "$ReleaseName.zip"
$Response = [System.Net.WebRequest]::Create($URL).GetResponse().ResponseUri
Invoke-WebRequest "$Response/$ReleaseNameZip".Replace('tag', 'download') `
    -OutFile $ReleaseNameZip

# Extract the downloaded archive
Expand-Archive -Path $ReleaseNameZip -DestinationPath .

Write-Info -N 'Done'

################## UPDATE SYSTEM BINARIES ##################

Write-Info " * Updating system SSH binaries using the extracted release ... "

# Access rule that grants ownership to system administrators
$AdminFullControlAccessRule = New-Object `
    -TypeName System.Security.AccessControl.FileSystemAccessRule `
    -ArgumentList 'BUILTIN\Administrators', 'FullControl', 'Allow'

# Needed so that ssh-agent.exe can be safely updated
Stop-Service ssh-agent

# Get list of all existing system SSH binaries
$SSHBinaries = (Get-ChildItem $SystemSSH).Name
$SSHBinaries | %{
    # Give full ownership of binary file to the system administrator
    # Fails with "Access to <path> denied" errors otherwise
    $Binary = "$SystemSSH\$_"
    $BinaryACL = Get-Acl -Path $Binary
    $BinaryACL.SetAccessRule($AdminFullControlAccessRule)
    $BinaryACL | Set-Acl -Path $Binary

    # Overwrite existing system binary
    Copy-Item -Force -Path "$ReleaseName\$_" -Destination $SystemSSH
}

# This is needed for first time update due to SSL compatibility issues
# From the second update, it is handled by the above loop
# Refer to https://github.com/PowerShell/Win32-OpenSSH/issues/2052
If (!$SSHBinaries.Contains('libcrypto.dll')) {
    Copy-Item -Path "$ReleaseName\libcrypto.dll" -Destination $SystemSSH
}

Write-Info -N 'Done'

#################### POST-SETUP CLEANUP ####################

Write-Info " * Cleaning up the script directory after setup ... "

# Restart previously stopped service
Start-Service ssh-agent

# Remove downloaded and extracted files
Remove-Item $ReleaseNameZip
Remove-Item -Recurse $ReleaseName

Write-Info -N 'Done'

Write-Host -ForegroundColor DarkGreen "`nCompleted OpenSSH setup."
