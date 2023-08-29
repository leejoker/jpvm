import cmd
import tables
import install
import clean
import distro
import list
import use
import current
import remove

proc commandLines(): Cmder =
  var commands = @[
    installCommand(),
    cleanCommand(),
    distroCommand(),
    listCommand(),
    useCommand(),
    currentCommand(),
    removeCommand()
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
