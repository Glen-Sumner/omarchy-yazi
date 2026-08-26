import QtQuick
import Quickshell
import Quickshell.Io

// Yazi Theme Sync service.
//
// On shell start: generates a yazi flavor for every Omarchy theme and
// activates the flavor matching the current theme. Afterwards it watches
// ~/.local/state/omarchy/current/theme.name and re-syncs yazi whenever
// the active theme changes.
//
// Security notes:
// - Every helper launch runs under a hard deadline: SIGTERM at deadlineMs,
//   escalating to SIGKILL killGraceMs later, so a wedged helper can never
//   outlive the shell.
// - The watched state file is user-writable and could be swapped for a
//   FIFO, symlink, or directory at any time. The watcher therefore never
//   loads it (preload: false), and every single sync first runs a type
//   guard that accepts only a regular, non-symlink file (exit 75).
// - The generator independently bounds its reads and validates theme
//   names before any path interpolation (see bin/omarchy-yazi-flavor).
Item {
  id: root

  property var shell: null

  readonly property string scriptPath: {
    var url = Qt.resolvedUrl("bin/omarchy-yazi-flavor").toString()
    return url.startsWith("file://") ? url.substring(7) : url
  }
  readonly property string themeStateFile: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme.name"

  // Hard deadline for helper processes.
  readonly property int deadlineMs: 30000
  readonly property int killGraceMs: 5000

  function busy() {
    return syncProc.running || termTimer.running || killTimer.running
  }

  // Launch the generator. Paths are passed as argv (never interpolated
  // into shell text). Single syncs run a preamble type guard on the state
  // file first; --all does not need the state file up front.
  function sync(rebuildAll) {
    if (busy())
      return
    var body = 'script=$1; state=$2\n'
    if (!rebuildAll)
      body += '[ -f "$state" ] && [ ! -L "$state" ] || exit 75\nexec "$script"'
    else
      body += '"$script" --all && exec "$script"'
    syncProc.command = ["setsid", "bash", "-c", body, "omarchy-yazi-sync", scriptPath, themeStateFile]
    syncProc.running = true
    termTimer.restart()
  }

  Process {
    id: syncProc

    onExited: function(exitCode) {
      termTimer.stop()
      killTimer.stop()
      if (exitCode === 75)
        console.warn("omarchy-yazi: theme state file failed the safety check (not a regular file); skipped sync")
      else if (exitCode !== 0)
        console.warn("omarchy-yazi: sync failed with exit code", exitCode)
    }
  }

  Timer {
    id: termTimer

    interval: root.deadlineMs
    onTriggered: {
      if (!syncProc.running)
        return
      console.warn("omarchy-yazi: helper exceeded", root.deadlineMs, "ms deadline; sending SIGTERM")
      syncProc.signal(15)
      killTimer.restart()
    }
  }

  Timer {
    id: killTimer

    interval: root.killGraceMs
    onTriggered: {
      if (!syncProc.running)
        return
      console.warn("omarchy-yazi: helper ignored SIGTERM; sending SIGKILL")
      syncProc.signal(9)
    }
  }

  FileView {
    id: themeWatcher

    path: root.themeStateFile
    watchChanges: true
    preload: false
    onFileChanged: root.sync(false)
  }

  Component.onCompleted: root.sync(true)
}
