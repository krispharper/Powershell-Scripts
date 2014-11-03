# Get-HexDump.ps1
# Written by Bill Stewart (bstewart@iname.com)

#requires -version 2

<#
.SYNOPSIS
Outputs the contents of a file as a hex dump.

.DESCRIPTION
Outputs the contents of a file as a hex dump. This is useful for viewing the content of a binary file. Characters outside the range of standard printable ASCII range are output using a dot (.) by default. Use the -UnprintableChar parameter to specify a different character.

.PARAMETER Path
Specifies the path to a file. Wildcards are not permitted. The parameter name ("Path") is optional.

.PARAMETER UnprintableChar
Specifies the character to use for output of characters in the file that are outside of the standard printable ASCII character range. The default value is a dot (".").

.PARAMETER BufferSize
Specifies the buffer size to use. The file will be read this many bytes at a time. This parameter must be a multiple of 16. The default is 65536 (64KB).
#>

param(
  [parameter(Position=0,Mandatory=$TRUE)]
    [String] $Path,
    [Char] $UnprintableChar = ".",
    [UInt32] $BufferSize = 65536
)

if ( -not (test-path -literalpath $Path) ) {
  write-error "Path '$Path' not found." -category ObjectNotFound
  exit
}

$item = get-item -literalpath $Path -force
if ( -not ($? -and ($item -is [System.IO.FileInfo])) ) {
  write-error "'$Path' is not a file in the file system." -category InvalidType
  exit
}

if ( $item.Length -gt [UInt32]::MaxValue ) {
  write-error "'$Path' is too large." -category OpenError
  exit
}

# The file will be output in 16-byte lines.
$bytesPerLine  = 16

if ( $BufferSize % $bytesPerLine -ne 0 ) {
  write-error "-BufferSize parameter must be a multiple of $bytesPerLine." -category InvalidArgument
  exit
}

# Keep track of our position within the file.
[UInt32] $fileOffset = 0

try {
  $stream = [System.IO.File]::OpenRead($item.FullName)
  while ( $stream.Position -lt $stream.Length ) {
    # Read $BufferSize bytes into $buffer, returning $bytesRead.
    $buffer = new-object Byte[] $BufferSize
    $bytesRead = $stream.Read($buffer, 0, $BufferSize)
    # Step through buffer $bytesPerLine bytes at a time.
    for ( $line = 0; $line -lt [Math]::Floor($bytesRead / $bytesPerLine); $line++ ) {
      # Grab 16-byte buffer slice, and created formatted string.
      $slice = $buffer[($line * $bytesPerLine)..(($line * $bytesPerLine) + $bytesPerLine - 1)]
      $hexOutput = "{0:X8}  {01:X2} {02:X2} {03:X2} {04:X2} {05:X2} {06:X2} {07:X2} {08:X2} {09:X2} {10:X2} {11:X2} {12:X2} {13:X2} {14:X2} {15:X2} {16:X2} " -f (, $fileOffset + $slice)
      $charOutput = ""
      # Create ASCII printable character output.
      foreach ( $byte in $slice ) {
        if ( ($byte -ge 32) -and ($byte -le 126) ) {
          $charOutput += [Char] $byte
        }
        else {
          $charOutput += $UnprintableChar
        }
      }
      "{0} {1}" -f $hexOutput, $charOutput
      $fileOffset += $bytesPerLine
    }
    # Process bytes from end of file when file size not multiple of $bytesPerLine.
    if ( $bytesRead % $bytesPerLine -ne 0 ) {
      $slice = $buffer[($line * $bytesPerLine)..($bytesRead - 1)]
      $hexOutput = "{0:X8}  " -f $fileOffset
      $charOutput = ""
      foreach ( $byte in $slice ) {
        $hexOutput += "{0:X2} " -f $byte
        if ( ($byte -ge 32) -and ($byte -le 126) ) {
          $charOutput += [Char] $byte
        }
        else {
          $charOutput += $UnprintableChar
        }
      }
      # PadRight needed to align the output.
      "{0} {1}" -f $hexOutput.PadRight(58), $charOutput
    }
    write-progress -activity "Get-HexDump.ps1" `
      -status ("Dumping file '{0}'" -f $item.FullName) `
      -percentcomplete (($fileOffset / $stream.Length) * 100)
  }
}
catch [System.Management.Automation.MethodInvocationException] {
  throw $_
}
finally {
  $stream.Close()
}
