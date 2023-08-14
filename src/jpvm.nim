import cmd
import install_jdk
import clean
import tables

proc commandLines(): Cmder =
  var commands = @[installCommand(), cleanCommand()]
  registerCommands("jpvm [install|distro...] [--local] [distro] [version]", commands)

proc main() =
  var cmder = commandLines()
  var checkResult = validateParams(cmder)
  if checkResult:
    var commandLine = createCommandLine()
    var commandTable: Table[string, Command] = cmder.commands
    var command: Command = commandTable[commandLine.mainArgument]
    command.commandProc(commandLine)

when isMainModule:
  main()
