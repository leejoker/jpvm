import cmd
import jpvm_utils
import os

const CLEAN_HELP_USAGE = "clean"
const CLEAN_HELP_COMMENT = "清理缓存目录"

proc cleanProc(command: CommandLine) =
  let cacheDir = createDirs(getEnv("HOME"), ".jpvm", "cache")
  for kind, path in walkDir(cacheDir):
    case kind
    of pcFile, pcLinkToFile, pcLinkToDir: removeFile(path)
    of pcDir: removeDir(path, true)
  echo "清理缓存完成"

proc cleanCommand*(): Command =
  var commandLine = CommandLine(
    mainArgument: "clean"
  )
  Command(
    helpInfo: HelpInfo(
        usage: CLEAN_HELP_USAGE,
        comment: CLEAN_HELP_COMMENT
    ),
    commandLine: commandLine,
    commandProc: cleanProc
  )
