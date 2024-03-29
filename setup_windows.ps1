################################# WINDOWS SETUP ################################
# Install all necessary programs and tools required for the PDE and copy the
# configs to the appropriate system directories
Param (
    [Switch]$Update # Update the tools but do not copy configs when enabled
)
$ProgramDir = "$PWD\programs"

# Writes information to stdout in cyan color
Function Write-Info
{
    Param (
        [String]$Message,   # Information to write to host display
        [Switch]$N          # Add new-line at the end when enabled
    )

    If ($N) { Write-Host -ForegroundColor DarkCyan $Message }
    Else { Write-Host -NoNewline -ForegroundColor DarkCyan $Message }
}

# Downloads and installs the nightly version of a software for a user
function Install-Nightly
{
    Param (
        [String]$MiniURL,   # Nightly release mini URL
        [String]$File,      # Release file name
        [String]$SHA256     # SHA256 file extension
    )
    Write-Info -N "Installing $MiniURL -"
    $FileURL = "https://github.com/$MiniURL/releases/download/nightly/$File.zip"
    Set-Location $ProgramDir

    Write-Info " * Downloading release from '$FileURL' ... "
    Invoke-WebRequest $FileURL -OutFile "$File.zip"
    Write-Info -N 'Done'

    Write-Info " * Verifying SHA hash from '$FileURL.$SHA256' ... "
    $FileSHA = "$(Invoke-WebRequest "$FileURL.$SHA256")".Split()[0]
    If ($FileSHA -ne (Get-FileHash "$File.zip").Hash.ToLower()) {
        Write-Host -ForegroundColor Red "`n  ERROR: '$MiniURL' release file" + `
            ' SHA hash did not match. Aborting installation!'
        Return
    }
    Write-Info -N 'Done'

    Write-Info " * Extracting release to '$File' ... "
    If (Test-Path $File) { Remove-Item -Recurse $File }
    Expand-Archive -LiteralPath "$File.zip"
    $NestedDir = $(Get-ChildItem $File).FullName
    Move-Item -Path "$NestedDir\*" -Destination $File
    Remove-Item $NestedDir
    Remove-Item "$File.zip"
    Write-Info -N 'Done'

    Set-Location ..
    Write-Info -N 'Done.'
}

# Add given path to User PATH environment variable if not present
function Add-To-User-Path
{
    Param ( [String]$TargetPath )

    $PATH = [Environment]::GetEnvironmentVariable('PATH', 'User').Split( `
        ';', [StringSplitOptions]::RemoveEmptyEntries)
    If ($TargetPath -NotIn $PATH) {
        $PATH += $TargetPath, ''
        [Environment]::SetEnvironmentVariable('PATH', $PATH -Join ';', 'User')
        Write-Info -N "Added '$TargetPath' to User `$Env:PATH."
    }
}

# Install the configuration to the destination folder
function Install-Config
{
    Param ( [String]$Source, [String]$Destination )

    If ($Update) { Return }
    New-Item -Force -ItemType SymbolicLink -Path $Destination -Target $Source
}

function Run-Main
{
    Write-Host -ForegroundColor DarkGreen `
        "Executing script for PDE setup on Windows`n"

    # Install WezTerm (nightly) and its config
    Install-Nightly 'wez/wezterm' 'WezTerm-windows-nightly' 'sha256'
    Add-To-User-Path "$ProgramDir\WezTerm-windows-nightly"
    Install-Config "$PWD\wezterm" "$env:USERPROFILE\.config\wezterm"
    Write-Info -N

    # Install Neovim (nightly) and its config
    Install-Nightly 'neovim/neovim' 'nvim-win64' 'sha256sum'
    Add-To-User-Path "$ProgramDir\nvim-win64\bin"
    Install-Config "$PWD\nvim" "$env:LOCALAPPDATA\nvim"
    Write-Info -N

    # Install all dotfiles
    Install-Config "$PWD\dotfiles\.gitconfig" "$env:USERPROFILE\.gitconfig"

    # Install RipGrep
    Write-Info -N "Checking for RipGrep updates -"
    winget install BurntSushi.ripgrep.MSVC
    Write-Info -N "Done.`n"

    # Uninstall and reinstall git to use external OpenSSH
    #
    # This ensures that Git does not ship with internal SSH support and uses the
    # SSH binaries configured externally by the PATH environment variable
    # If both external and internal SSH binaries exist, git commit signing fails
    # since it mixes up the SSH binaries used for signing
    # Refer to https://github.com/git-for-windows/git/issues/3647
    # and https://github.com/microsoft/winget-cli/discussions/3462
    # TODO: check git version, do not update if already latest version
    Write-Info -N "Rebuilding GIT with support for external OpenSSH -"
    winget uninstall Git.Git
    winget install --id=Git.Git --custom '/o:SSHOption=ExternalOpenSSH'
    Write-Info -N "Done.`n"

    Write-Host -ForegroundColor DarkGreen "Completed PDE setup"
}

Run-Main
