import ../../cmd
import os
import json
import asyncdispatch
import jpvm_utils
import http_utils
import global

const INSTALL_HELP_USAGE = "install [distro] [version]"
const INSTALL_HELP_COMMENT = "不指定distro或者version的话默认安装OpenJDK最新的LTS版本, 例如： jpvm install openjdk 20"

proc downloadCache(distro: string, version: string, sys: string, arch: string,
    json: JsonNode): (string, string) =
  var cachePath = createDirs(cachePath, "jdks", distro)
  try:
    var url = json[distro][version][sys][arch]
    var (_, tail) = splitPath(url.getStr())
    echo "Download from " & url.getStr()
    var packagePath = joinPath(cachePath, tail)
    var (parentDir, packageName, _) = splitFile(packagePath)
    if not fileExists(packagePath):
      waitFor httpDownload(url.getStr(), packagePath)
      echo "Download Over, Unzipping the package"
    else:
      echo "Find Cache, Unzipping the package"
    packageName = distro & "-" & version
    var packageDirPath = joinPath(parentDir, packageName)
    unzipFiles(packagePath, packageDirPath)
    var finalDir = findBinDir(packageDirPath)
    return (finalDir, packageName)
  except KeyError:
    echo "找不到要安装的版本"
    quit(0)

proc installProc(command: CommandLine) =
  downloadVersionList()
  var json = parseJson(readFile(versionPath))
  var distro = "openjdk"
  var version = "17"
  var arch = sysArch()
  var sys = sysOS()
  if len(command.optArguments) != 0:
    if command.optArguments[0] != "":
      distro = command.optArguments[0]
    if len(command.optArguments) > 1 and command.optArguments[1] != "":
      version = command.optArguments[1]
  var (packageDirPath, packageName) = downloadCache(distro, version, sys, arch, json)
  var dirPath = createDirs(jdkPath, distro, version, sys, arch)
  var p = joinPath(dirPath, packageName)
  moveJpvmDir(packageDirPath, p)
  echo "Success!"

proc installCommand*(): Command =
  var commandLine = CommandLine(
    mainArgument: "install",
    optArguments: @["distro", "version"]
  )
  Command(
    helpInfo: HelpInfo(
        usage: INSTALL_HELP_USAGE,
        comment: INSTALL_HELP_COMMENT
    ),
    commandLine: commandLine,
    commandProc: installProc
  )
