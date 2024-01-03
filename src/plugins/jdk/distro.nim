import json
import os
import strutils
import cmd
import global
import jpvm_utils
import draw_table

const DISTRO_HELP_USAGE = "distro"
const DISTRO_HELP_COMMENT = "查看支持的发行版"


proc distroProc(command: CommandLine) =
  downloadVersionList(false)
  let json = parseJson(readFile(versionPath))
  var table = createTable("Name", "Latest LTS", "Installed", "InstalledVersion")
  for key in json.keys:
    var name = key
    var latestLTS: string
    var installed = false
    var installedVersion: seq[string]
    for v in json[key].keys:
      if json[key][v].contains("LTS"):
        latestLTS = v
        break
    if os.dirExists(joinPath(jdkPath, key)):
      installed = true
      for (k, p) in walkDir(joinPath(jdkPath, key)):
        var (_, t) = splitPath(p)
        installedVersion.add(t)
    table.addRow(name, latestLTS, $installed, join(installedVersion, ", "))
  $table

proc distroCommand*(): Command =
  var commandLine = CommandLine(
    mainArgument: "distro"
  )
  Command(
    helpInfo: HelpInfo(
        usage: DISTRO_HELP_USAGE,
        comment: DISTRO_HELP_COMMENT
    ),
    commandLine: commandLine,
    commandProc: distroProc
  )
