import std/tables

type
  CommandLine* = object of RootObj
    mainArgument*: string
    optArguments*: seq[string]
    flags*: Table[string, string]
  CommandProc* = proc (command: CommandLine)
  Command* = object of RootObj
    commandLine*: CommandLine
    commandProc*: CommandProc
    helpInfo*: string
  Cmder* = object of RootObj
    baseUsage*: string
    commands*: Table[string, Command]

proc newLine(): string =
  when defined windows:
    return "\r\n"
  elif defined linux:
    return "\n"
  else:
    return "\n"

proc commandTable(commands: seq[Command]): Table[string, Command] =
  for c in commands:
    result[c.commandLine.mainArgument] = c

proc registerCommands*(baseUsage: string, commands: seq[Command]): Cmder =
  Cmder(
      baseUsage: baseUsage,
      commands: commandTable(commands)
  )

proc helpInfo*(cmder: Cmder) =
  var helpInfo = newLine() & "Usage: " & cmder.baseUsage & newLine() & newLine()
  var commands = cmder.commands
  for (name, c) in pairs(commands):
    helpInfo = helpInfo & c.helpInfo & newLine()
  echo helpInfo
