<#
.SYNOPSIS
Gets the outlook inbox from exchange for the current user

.PARAMETER folderName
The name of the folder for which all items should be marked as read

.PARAMETER itemsToCheck
The number of unread items to grab. It's possible to do this for all unread mail, but will probably be slower
#>

param (
    [string] $folderName = "Notifications",
    [int] $itemsToCheck = 100
)

$emailAddress = ([adsisearcher]"(samaccountname=$env:USERNAME)").FindOne().Properties.mail
$namespace = "Microsoft.Exchange.WebServices.Data.{0}"

[Reflection.Assembly]::LoadFile("C:\Program Files (x86)\Microsoft\Exchange\Web Services\2.0\Microsoft.Exchange.WebServices.dll") | Out-Null
$service = New-Object ($namespace -f "ExchangeService")([Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2007_SP1)
$service.AutodiscoverUrl($emailAddress)
$inbox = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($service,[Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Inbox)

$displayNameProperty = [Microsoft.Exchange.WebServices.Data.FolderSchema]::DisplayName

$folderView = New-Object ($namespace -f "FolderView")($inbox.ChildFolderCount)
$propertySet = New-Object ($namespace -f "PropertySet")([Microsoft.Exchange.WebServices.Data.BasePropertySet]::IdOnly, $displayNameProperty, [Microsoft.Exchange.WebServices.Data.FolderSchema]::ChildFolderCount)
$folderView.PropertySet = $propertySet
$filter = New-Object ($namespace -f "SearchFilter+IsEqualTo")($displayNameProperty, $folderName)
$folder = ($inbox.FindFolders($filter, $folderView) | Select-Object -First 1)

function Mark-AllAsRead ($folder) {
    Write-Host $folder.DisplayName
    $isReadProperty = [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::IsRead

    if ($folder.ChildFolderCount -eq 0) {
        #Write-Host "`tLeaf folder"
        $itemView = New-Object ($namespace -f "ItemView")($itemsToCheck)
        $propertySet = New-Object ($namespace -f "PropertySet")([Microsoft.Exchange.WebServices.Data.BasePropertySet]::IdOnly, $isReadProperty)
        $itemView.PropertySet = $propertySet
        $filter = New-Object ($namespace -f "SearchFilter+IsEqualTo")($isReadProperty, $false)
        $unreadMail = $folder.FindItems($filter, $itemView)

        $unreadMail |% {$_.IsRead = $true; $_.Update([Microsoft.Exchange.WebServices.Data.ConflictResolutionMode]::AutoResolve)}
    }
    else {
        #Write-Host "`tParent folder"
        $folderView = New-Object ($namespace -f "FolderView")($folder.ChildFolderCount)
        $folder.FindFolders($folderView) |% {Mark-AllAsRead $_}
    }
}

Mark-AllAsRead $folder

