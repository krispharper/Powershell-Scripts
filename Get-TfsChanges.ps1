<#
.SYNOPSIS
This script will get all changesets from a specific date as well as all files that have changed since that date and write the results to two .csv files.

.PARAMETER sinceDate
The cutoff date for changes
#>
param (
    [parameter(Mandatory=$true)]
    [DateTime] $sinceDate
)

$tfsServer = (Get-TfsServer -Name nydevtfs01/NLY)
$changes = Get-TfsItemHistory -Recurse -HistoryItem C:\NLY |? {$_.CreationDate -gt $sincedate} 
$changes |% {$_.Comment = $_.Comment -replace "`r`n", ""}
#$changes | Select-Object -Property ChangesetId, Owner, Creationdate, Comment | ConvertTo-Csv -NoTypeInformation > Changes.csv
$changeDetails = @()
$count = 0
$changesCount = $changes.Count

$changes |% {
    $changeset = Get-TfsChangeset -ChangesetNumber $_.ChangesetId -Server $tfsServer
    "Processing {0} of {1}. This changeset (ID {2}) has {3} change(s)." -f $count, $changesCount, $changeset.ChangesetId, $changeset.Changes.Count
    $changeset.Changes |% {
        $changeDetails += (New-Object PsObject -Property @{
            "ChangesetId" = $changeset.ChangesetId;
            "Owner" = $changeset.Owner;
            "CheckinDate" = $_.Item.CheckinDate;
            "ChangeType" = $_.ChangeType;
            "ServerItem" = $_.Item.ServerItem
        })
    }
    $count++
}

$changeDetails | ConvertTo-Csv -NoTypeInformation > ChangeDetails.csv
