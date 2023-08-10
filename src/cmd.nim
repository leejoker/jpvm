import tables
import parseopt
import os
import jpvm_utils

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

proc createCommandLine*(): CommandLine =
  var p = initOptParser(commandLineParams())
  var commandLine = CommandLine()
  while true:
    p.next()
    case p.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      if p.val == "":
        commandLine.flags[p.key] = ""
      else:
        commandLine.flags[p.key] = p.val
    of cmdArgument:
      if commandLine.mainArgument == "":
        commandLine.mainArgument = p.key
      else:
        commandLine.optArguments.add(p.key)
  return commandLine

proc validateParams*(cmder: Cmder): bool =
  if paramCount() == 0:
    cmder.helpInfo()
    false
  else:
    true
