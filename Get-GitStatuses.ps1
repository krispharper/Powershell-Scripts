<#
.SYNOPSIS
Recursively checks a directory for git repositories and displays their statuses

.PARAMETER rootPath
The directory root which holds all the git repositories to be checked
#>

param (
    [string] $rootPath = "~"
)

Push-Location -StackName s .

ls $rootPath -Attributes Directory -Force -Name -R -Filter .git |% {
    cd (Join-Path -Path $rootPath -ChildPath $_)
    cd ..
    $status = git status -s

    if ($status) {
        $_
        git status -s
    }
}

Pop-Location -StackName s
