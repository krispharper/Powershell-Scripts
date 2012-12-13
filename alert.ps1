Add-Type -AssemblyName "System.Windows.Forms"
(New-Object System.Media.SoundPlayer "C:\Windows\Media\chimes.wav").Play()
[System.Windows.Forms.MessageBox]::Show("The task has finished.", "Task Done")
