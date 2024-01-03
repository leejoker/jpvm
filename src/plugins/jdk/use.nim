import cmd
import global
import jpvm_utils

const USE_HELP_USAGE = "use {distro} {version}"
const USE_HELP_COMMENT = "使用指定版本, 例如: jpvm use openjdk 17"

proc useProc(command: CommandLine) =
  var (distro, version, path) = jdkVersionPath(command.optArguments)
  if path != "":
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
