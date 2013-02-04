<#
.SYNOPSIS
Renames the files passed in using regular expressions.

.DESCRIPTION
Uses the InPattern and OutPattern parameters to rename a file list. These can be regular expressions. This script has the option to preview changes by using the -n option.

.PARAMETER Files
The list of files to rename.

.PARAMETER n
A switch to only display the output of the renaming action without actually making changes.

.PARAMETER InPattern
The pattern to match in the passed in filenames.

.PARAMETER OutPattern
The replacement expression

.EXAMPLE
PS C:\SomeDirectory> ls | rename -n "little" "BIG"

Lists the changes that would be made by replacing "little" with "BIG" in all files in the current directory.

.EXAMPLE
PS C:\SomeDirectory> ls | rename "Some-Prefix(.*)Some-Suffix" "`$1"

Renames all files in the current directory by removing the prefix "Some-Prefix" and the suffix "Some-Suffix".
#>
param
(
    [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [alias('FullName')]
    [string[]] $Files,

    [switch] $n,

    [Parameter(Position=1, Mandatory=$true)]
    [string] $InPattern,

    [Parameter(Position=2, Mandatory=$true)]
    [AllowEmptyString()]
    [string] $OutPattern
)

process
{
    foreach($file in $Files)
    {
        $oldName = $(Get-Item $file).Name 
        $newName = $oldName -Replace $InPattern, $OutPattern
        
        if ($oldName -cne $newName)
        {
            if ($n.IsPresent)
            {
                $oldName + " will be renamed as " + $newName
            }
            else
            {
                Rename-Item $file $newName
            }
        }
    }
}
