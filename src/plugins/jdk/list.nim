import json
import os
import cmd
import global
import tables
import jpvm_utils
import draw_table

const LIST_HELP_USAGE = "list [--local]"
const LIST_HELP_COMMENT = "查看所有发行版，增加 --local 参数后，查看已安装的发行版"

proc listProc(command: CommandLine) =
  downloadVersionList(false)
  let onlyLocal = command.flags.contains("local")
  let json = parseJson(readFile(versionPath))
  var table = createTable("Name", "Version", "LTS", "Installed")
  for key in json.keys:
    var name = key
    for v in json[key].keys:
      var lts = false
      var installed = false
      var version: string
      if json[key][v].contains("LTS"):
        lts = true
      version = v
      if os.dirExists(joinPath(jdkPath, key)):
        for (k, p) in walkDir(joinPath(jdkPath, key)):
          var (_, t) = splitPath(p)
          if version == t:
            installed = true
      if onlyLocal and not installed:
        continue
      else:
        table.addRow(name, version, $lts, $installed)
  $table

proc listCommand*(): Command =
  var commandLine = CommandLine(
    mainArgument: "list"
  )
  Command(
    helpInfo: HelpInfo(
        usage: LIST_HELP_USAGE,
        comment: LIST_HELP_COMMENT
    ),
    commandLine: commandLine,
    commandProc: listProc
  )
