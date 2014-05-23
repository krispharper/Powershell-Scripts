$machineNames = (
    "\\pc-kharper\",
    "\\pc-kharper2\",
    "\\pc-devbberg\"
)

$rootDirs = (
    "c$\Users\kharper\Desktop\",
    "c$\Users\Public\Desktop\",
    "c$\Users\kharper\AppData\Roaming\Microsoft\Windows\Start Menu\",
    "c$\Users\kharper\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
)

$annalyShortcuts = (
    "XBasis QA.lnk",
    "XBasis Clone.lnk",
    "XBasis Redux.lnk",
    "HostExplorer.lnk",
    "Dashboard.lnk",
    "FRx (GP2010).lnk",
    "PolyPaths.lnk",
    "PolyPaths 64.lnk",
    "ACAT QA.lnk"
)

$rcapShortcuts = (
    "PnL QA.lnk",
    "PnL.lnk"
)

function Delete-Shortcuts ($shortcuts, $destDirName, $rootDirs, $machineNames) {
    $startMenuPath = "c$\Users\kharper\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\"

    foreach ($machineName in $machineNames) {
        $destDir = (Join-Path ($machineName + $startMenuPath) $destDirName)

        if (!(Test-Path $destDir)) {
            mkdir $destDir
        }

        foreach ($dirName in $rootDirs) {
            $dir = ($machineName + $dirName)

            foreach ($shortcut in $shortcuts) {
                $path = (Join-Path $dir $shortcut)

                if (Test-Path $path) {
                    "Moving $path to $destDir"
                    mv -Force $path $destDir
                }
            }
        }
    }
}

Delete-Shortcuts $annalyShortcuts "Annaly" $rootDirs $machineNames
Delete-Shortcuts $rcapShortcuts "RCap Securities" $rootDirs $machineNames
