import cmd
import global
import strutils
import os
import strformat

const CURRENT_HELP_USAGE = "current"
const CURRENT_HELP_COMMENT = "获取当前使用的JDK版本"

proc currentProc(command: CommandLine) =
  var line = readFile(curVersionPath)
  if (not fileExists(curVersionPath)) or (len(line) == 0):
    echo "请先使用use命令指定版本"
  else:
    var array = line.split(" ")
    echo fmt"Current JDK Version: {array[0]} {array[1]}"

proc currentCommand*(): Command =
  var commandLine = CommandLine(
    mainArgument: "current"
  )
  Command(
    helpInfo: HelpInfo(
        usage: CURRENT_HELP_USAGE,
        comment: CURRENT_HELP_COMMENT
    ),
    commandLine: commandLine,
    commandProc: currentProc
  )
