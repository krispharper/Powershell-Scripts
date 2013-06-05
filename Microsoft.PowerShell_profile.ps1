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
Set-Alias vim "C:\Program Files (x86)\Vim\vim73\vim.exe"
Set-Alias gvim "C:\Program Files (x86)\Vim\vim73\gvim.exe"
Set-Alias tf "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\tf.exe"
Set-Alias paint "C:\Windows\System32\mspaint.exe"
Set-Alias putty "C:\Program Files (x86)\Putty\putty.exe"
Set-Alias python "C:\Program Files (x86)\IronPython 2.7\ipy.exe"

Set-Alias alert Display-Alert
Set-Alias cal Write-Calendar
Set-Alias rename Rename-Items

Remove-Item alias:cd
Set-Alias cd Change-Directory

# Include TFS PowerTools commands
if (-not (Get-PSSnapin Microsoft.TeamFoundation.PowerShell)) {
    Add-PSSnapin Microsoft.TeamFoundation.PowerShell
}

# Set up prompt including the posh-git module
Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)
Import-Module posh-git

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
        $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
    }
    
    $green = [ConsoleColor]::Green
    $cyan = [ConsoleColor]::Cyan
    $hostName = [Net.Dns]::GetHostName()

    # If we're in a remote session, overwrite the generated prompt
    if ($PSSenderInfo) {
        $promptLength = $hostName.Length + 4
        (("`b" * $promptLength) + (" " * $promptLength) + ("`b" * $promptLength) + "$ ")
    }

    # Write the hostname and a shortened version of the current path
    Write-Host ("[" + $hostName + "] ") -n -f $green
    Write-Host ("<" + (Shorten-Path (pwd).Path) + ">") -n -f $cyan

    if ($provider -eq "FileSystem") {
        Write-VcsStatus

        $global:LASTEXITCODE = $realLASTEXITCODE
    }

    return "$ "
}

Enable-GitColors

Pop-Location
