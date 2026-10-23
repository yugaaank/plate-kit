pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common.functions
import QtCore
import QtQuick
import Quickshell

Singleton {
    // XDG dirs, with "file://"
    readonly property string home: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
    readonly property string config: StandardPaths.standardLocations(StandardPaths.ConfigLocation)[0]
    readonly property string state: StandardPaths.standardLocations(StandardPaths.StateLocation)[0]
    readonly property string cache: StandardPaths.standardLocations(StandardPaths.CacheLocation)[0]
    readonly property string genericCache: StandardPaths.standardLocations(StandardPaths.GenericCacheLocation)[0]
    // $XDG_RUNTIME_DIR: 0700, per user, on tmpfs. What lives here is screen and clipboard
    // content, so it never sits in a directory every account on the machine can read.
    readonly property string runtime: StandardPaths.standardLocations(StandardPaths.RuntimeLocation)[0]
    readonly property string documents: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
    readonly property string downloads: StandardPaths.standardLocations(StandardPaths.DownloadLocation)[0]
    readonly property string pictures: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
    readonly property string music: StandardPaths.standardLocations(StandardPaths.MusicLocation)[0]
    readonly property string videos: StandardPaths.standardLocations(StandardPaths.MoviesLocation)[0]

    // The kit's own dirs and files. Kit.qml's `name` has to agree with the config dir.
    readonly property string kitName: "plate-kit"
    // Apps made with the kit persist settings in their own config, never a shared shell's.
    property string kitConfigDir: FileUtils.trimFileProtocol(`${Directories.config}/${Directories.kitName}`)
    property string kitConfigName: "config.json"
    property string kitConfigPath: `${Directories.kitConfigDir}/${Directories.kitConfigName}`
    // Bundle-adjacent files that travelled with the kit (fonts, icons).
    property string assetsPath: Quickshell.shellPath("assets")

    // Wallpaper-derived palette (colors.json written by matugen on a system that sets it up).
    // On a machine without the color pipeline, apps fall back to Appearance's built-in colors.
    property string generatedMaterialThemePath: FileUtils.trimFileProtocol(`${Directories.state}/user/generated/colors.json`)

    // Cleanup on init
    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", `${Directories.kitConfigDir}`])
    }
}
