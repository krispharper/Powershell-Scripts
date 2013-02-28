$rootDirs = (
    "\\pc-kharper2\c$\Users\kharper\AppData\Roaming\Microsoft\Windows\Start Menu\",
    "\\pc-kharper2\c$\Users\kharper\\Desktop\",
    "\\pc-devbberg\c$\Users\kharper\Desktop\"
)

$annalyShortcuts = (
    "XBasis QA.lnk",
    "XBasis Clone.lnk",
    "XBasis Redux.lnk",
    "HostExplorer.lnk"
)

$rcapShortcuts = (
    "PnL QA.lnk",
    "PnL.lnk"
)


function Delete-Shortcuts ($shortcuts, $dirName, $rootDirs) {
    $startMenuPath = $rootDirs[0]

    if (!(Test-Path ($startMenuPath + "Programs\$dirName"))) {
        mkdir ($startMenuPath + "Programs\$dirName")
    }

    foreach ($dir in $rootDirs) {
        foreach ($shortcut in $shortcuts) {
            $path = $dir + $shortcut

            if (Test-Path ($startMenuPath + $shortcut)) {
                if (Test-Path ($startMenuPath + "Programs\$dirName\" + $shortcut)) {
                    rm ($startMenuPath + $shortcut)
                }
                else {
                    mv ($startMenuPath + $shortcut) ($startMenuPath + "Programs\$dirName\")
                }
            }

            if (Test-Path $path) {
                rm $path
            }
        }
    }
}

Delete-Shortcuts $annalyShortcuts "Annaly" $rootDirs
Delete-Shortcuts $rcapShortcuts "RCap Securities" $rootDirs
