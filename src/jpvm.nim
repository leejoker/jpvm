import cmd
import install_jdk
import tables

proc commandLines(): Cmder =
  var commands = @[installCommand()]
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
