import cmd
import jpvm_utils
import os

const CLEAN_HELP_INFO = "clean  清理缓存目录"

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
      helpInfo: CLEAN_HELP_INFO,
      commandLine: commandLine,
      commandProc: cleanProc
  )
