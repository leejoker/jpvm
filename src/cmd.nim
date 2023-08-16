import tables
import parseopt
import os
import strutils
import jpvm_utils

const HELPINFO_SPACE = "    "

type
  HelpInfo* = object of RootObj
    usage*: string
    comment*: string
  CommandLine* = object of RootObj
    mainArgument*: string
    optArguments*: seq[string]
    flags*: Table[string, string]
  CommandProc* = proc (command: CommandLine)
  Command* = object of RootObj
    commandLine*: CommandLine
    commandProc*: CommandProc
    helpInfo*: HelpInfo
  Cmder* = object of RootObj
    baseUsage*: string
    commands*: OrderedTable[string, Command]

proc generateHelpInfoMessage(mainUsage: var string, commands: OrderedTable[
    string, Command]): string =
  var maxLen = 0
  var helpInfo = mainUsage
  for (name, c) in pairs(commands):
    var usageLen = c.helpInfo.usage.len()
    if maxLen == 0:
      maxLen = usageLen
    else:
      maxLen = if usageLen > maxLen: usageLen else: maxLen
  for (_, c) in pairs(commands):
    var usage = c.helpInfo.usage & " ".repeat(maxLen - c.helpInfo.usage.len())
    helpInfo = helpInfo & usage & HELPINFO_SPACE & c.helpInfo.comment & newLine()
  return helpInfo

proc commandTable(commands: seq[Command]): OrderedTable[string, Command] =
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
  helpInfo = generateHelpInfoMessage(helpInfo, commands)
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
