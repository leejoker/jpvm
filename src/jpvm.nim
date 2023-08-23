import cmd
import tables
import install_jdk
import clean
import distro
import list

proc commandLines(): Cmder =
  var commands = @[
    installCommand(),
    cleanCommand(),
    distroCommand(),
    listCommand()
  ]
  registerCommands("jpvm [install|distro...] [--local] [distro] [version]", commands)

proc main() =
  var cmder = commandLines()
  var checkResult = validateParams(cmder)
  if checkResult:
    var commandLine = createCommandLine()
    var commandTable: OrderedTable[string, Command] = cmder.commands
    var command: Command = commandTable[commandLine.mainArgument]
    command.commandProc(commandLine)

when isMainModule:
  main()
