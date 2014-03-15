if (!$env:home) {
    # Annaly profile location
    $profilePath = "\\nyprodfs01\profiles$\kharper"

    if (Test-Path $profilePath) {
        $env:home = $profilePath
    }
    else {
        $env:home = $env:homedrive + $env:homepath
    }
}

# Map '~' to $env:home and add my scripts to the PATH
$(Get-PSProvider FileSystem).Home = $env:Home
$env:Path += ";" + (Join-Path -Path $env:home -ChildPath "My Documents\WindowsPowerShell")

# Set up some common command aliases
Set-Alias which Get-Command
Set-Alias np "C:\Program Files (x86)\Notepad++\notepad++.exe"
Set-Alias vim "C:\Program Files (x86)\Vim\vim74\vim.exe"
Set-Alias gvim "C:\Program Files (x86)\Vim\vim74\gvim.exe"
Set-Alias tf "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\tf.exe"
Set-Alias paint "C:\Windows\System32\mspaint.exe"

Set-Alias alert Display-Alert
Set-Alias cal Write-Calendar
Set-Alias rename Rename-Items
Set-Alias colors Write-ColorScheme
Set-Alias Get-App cinst
Set-Alias Remove-App cuninst

Remove-Item alias:cd
Set-Alias cd Change-Directory

# Include TFS PowerTools commands
Add-PSSnapin Microsoft.TeamFoundation.PowerShell -ErrorAction SilentlyContinue

# Set up a shortcut to list all active sessions on remote servers I use
function Show-ActiveSessions {
    $serversXml = [xml](cat '\\nyprodfs01\profiles$\kharper\My Documents\Main Group.rdg')
    $serversXml.rdcman.file.group[1].server.name | Get-LoggedInUsers | Select-Object Server, Username, State | Sort-Object -Property State
}

# Set up prompt including the posh-git module
#Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)
#Import-Module posh-git

function Shorten-Path([string] $path) {
   $loc = $path.Replace($env:home, '~')
   # remove prefix for UNC paths
   $loc = $loc -replace '^[^:]+::', ''
   # make path shorter like tabs in Vim,
   # handle paths starting with \\ and . correctly
   return ($loc -replace '\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2')
}

# Set up a simple prompt, adding the git prompt parts inside git repos
function prompt {
    $provider = (pwd).Provider.Name

    # Only try to load posh-git functionality in filesystem providers
    if ($provider -eq "FileSystem") {
        $realLASTEXITCODE = $LASTEXITCODE

        # Reset color, which can be messed up by Enable-GitColors
        #$Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
    }
    
    $green = [ConsoleColor]::Green
    $cyan = [ConsoleColor]::Cyan
    $darkCyan = [ConsoleColor]::DarkCyan
    $white = [ConsoleColor]::White
    $hostName = [Net.Dns]::GetHostName()

    # If we're in a remote session, overwrite the generated prompt
    if ($PSSenderInfo) {
        $promptLength = $hostName.Length + 4
        (("`b" * $promptLength) + (" " * $promptLength) + ("`b" * $promptLength) + "$ ")
    }

    # Write the hostname and a shortened version of the current path
    $path = (Shorten-Path (pwd).Path) -replace "\\$"
    $path = $path -replace "\\", " $([char]0xE0B1) "
    Write-Host " $hostName " -n -f $white -b $green
    Write-Host "$([char]0xE0B0) " -n -f $green -b $darkCyan
    Write-Host $path -n -f $white -b $darkCyan
    Write-Host $([char]0xE0B0) -n -f $darkCyan

    if ($provider -eq "FileSystem") {
        #Write-VcsStatus

        $global:LASTEXITCODE = $realLASTEXITCODE
    }

    return " "
}

#Enable-GitColors

Pop-Location
