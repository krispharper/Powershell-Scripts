$(Get-PSProvider FileSystem).Home = '\\nyprodfs01\profiles$\kharper'
New-Alias which get-command
New-Alias np "C:\Program Files (x86)\Notepad++\notepad++.exe"
New-Alias vim "C:\Program Files (x86)\Vim\vim73\vim.exe"
New-Alias gvim "C:\Program Files (x86)\Vim\vim73\gvim.exe"
New-Alias tf "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe"
New-Alias paint "C:\Windows\System32\mspaint.exe"
New-Alias putty "C:\Program Files (x86)\Putty\putty.exe"

Remove-Item alias:cd
Set-Alias cd '\\nyprodfs01\profiles$\kharper\My Documents\WindowsPowerShell\cd.ps1'
