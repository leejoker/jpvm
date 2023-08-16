import strutils

type
  DrawTable* = object of RootObj
    header*: seq[string]
    body*: seq[seq[string]]
    maxWidth: seq[int]

proc divider(table: DrawTable) =
  var tableWidth = 0
  for col in table.maxWidth:
    tableWidth += col
  echo repeat("=", tableWidth + len(table.maxWidth) * 5 + 1)

proc header(table: DrawTable) =
  var line = ""
  for i, v in table.header:
    var space = repeat(" ", 2)
    line = line & "|" & space & v & repeat(" ", table.maxWidth[i] - len(v)) & space
  echo line & "|"

proc row(table: DrawTable) =
  for line in table.body:
    var lineStr = ""
    for i, v in line:
      var space = repeat(" ", 2)
      lineStr = lineStr & "|" & space & v & repeat(" ", table.maxWidth[i] - len(v)) & space
    lineStr = lineStr & "|"
    echo lineStr

proc createTable*(headers: varargs[string]): DrawTable =
  var table = DrawTable()
  for v in headers:
    table.header.add(v)
    table.maxWidth.add(len(v))
  return table

proc addRow*(table: var DrawTable, row: varargs[string]) =
  var rowBody: seq[string]
  for i, v in row:
    var l = len(v)
    if l > table.maxWidth[i]:
      table.maxWidth[i] = l
    rowBody.add(v)
  table.body.add(rowBody)

proc `$`*(table: DrawTable) =
  table.divider()
  table.header()
  table.divider()
  table.row()
  table.divider()
