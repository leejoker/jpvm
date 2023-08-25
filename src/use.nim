import cmd
import global
import jpvm_utils
import os

const USE_HELP_USAGE = "use {distro} {version}"
const USE_HELP_COMMENT = "使用指定版本, 例如: jpvm use openjdk 17"

proc useProc(command: CommandLine) =
  var distro: string
  var version: string
  if len(command.optArguments) != 0:
    if command.optArguments[0] != "":
      distro = command.optArguments[0]
    else:
      echo "请指定发行版信息"
      return
    if len(command.optArguments) > 1 and command.optArguments[1] != "":
      version = command.optArguments[1]
    else:
      echo "请指定版本"
      return
  else:
    echo "请指定发行版和版本号"
    return
  var arch = sysArch()
  var sys = sysOS()
  var dirPath = createDirs(jdkPath, distro, version, sys, arch)
  var packageName = distro & "-" & version
  var path = joinPath(dirPath, packageName)
  writeProfile("JAVA_HOME", path)
  var f = open(curVersionPath, fmWrite)
  f.writeLine(distro & " " & version)
  f.close()

proc useCommand*(): Command =
  var commandLine = CommandLine(
    mainArgument: "use"
  )
  Command(
    helpInfo: HelpInfo(
        usage: USE_HELP_USAGE,
        comment: USE_HELP_COMMENT
    ),
    commandLine: commandLine,
    commandProc: useProc
  )
