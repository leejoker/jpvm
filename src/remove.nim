import cmd
import jpvm_utils
import os
import strformat
import global

const REMOVE_HELP_USAGE = "remove [distro] [version]"
const REMOVE_HELP_COMMENT = "移除指定版本"

proc removeProc(command: CommandLine) =
  var (distro, version, path) = jdkVersionPath(command.optArguments)
  if path != "":
    removeDir(joinPath(jdkPath, distro, version))
    echo fmt"已移除版本 {distro}-{version}"


proc removeCommand*(): Command =
  var commandLine = CommandLine(
    mainArgument: "remove"
  )
  Command(
    helpInfo: HelpInfo(
        usage: REMOVE_HELP_USAGE,
        comment: REMOVE_HELP_COMMENT
    ),
    commandLine: commandLine,
    commandProc: removeProc
  )
