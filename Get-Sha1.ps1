param
(
    [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [alias('FullName')]
    [string[]] $Files
)
 
process
{
    [Reflection.Assembly]::LoadWithPartialName("System.Security") | out-null
    $sha1 = new-Object System.Security.Cryptography.SHA1Managed
    #$pathLength = (get-location).Path.Length + 1

    if ($Files.Count -gt 0)
    {
        foreach($file in $Files)
        {
            $filename = (Get-Item $file).FullName
            Write-Host $filename
            #$filenameDisplay = $filename.Substring($pathLength)
             
            #write-host $filenameDisplay

            $openFile = [System.IO.File]::Open($filename, "open", "read")
            $sha1.ComputeHash($openFile) | % { write-host -NoNewLine $_.ToString("x2") }

            $openFile.Dispose()

            write-host
        }
    }
}

