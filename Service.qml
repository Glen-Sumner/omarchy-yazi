import QtQuick
import Quickshell
import Quickshell.Io

// Yazi Theme Sync service.
//
// On shell start: generates a yazi flavor for every Omarchy theme and
// activates the flavor matching the current theme. Afterwards it watches
// ~/.local/state/omarchy/current/theme.name and re-syncs yazi whenever
// the active theme changes.
Item {
  id: root

  property var shell: null

  readonly property string scriptPath: {
    var url = Qt.resolvedUrl("bin/omarchy-yazi-flavor").toString()
    return url.startsWith("file://") ? url.substring(7) : url
  }
  readonly property string themeStateFile: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme.name"

  function sync(rebuildAll) {
    if (syncProc.running)
      return
    var cmd = scriptPath
    if (rebuildAll)
      cmd += " --all && " + scriptPath // full rebuild, then activate current theme
    syncProc.command = ["bash", "-c", cmd]
    syncProc.running = true
  }

  Process {
    id: syncProc

    onExited: function(exitCode) {
      if (exitCode !== 0)
        console.warn("omarchy-yazi: sync failed with exit code", exitCode)
    }
  }

  FileView {
    id: themeWatcher

    path: root.themeStateFile
    watchChanges: true
    onFileChanged: root.sync(false)
  }

  Component.onCompleted: root.sync(true)
}
