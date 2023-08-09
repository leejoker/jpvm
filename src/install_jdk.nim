import cmd, asyncdispatch, httpclient, os, json, zippy/ziparchives,
    zippy/tarballs, osproc, strutils

const INSTALL_HELP_INFO = "install [distro] [version]    不指定distro或者version的话默认安装最新的LTS版本, 例如： jpvm install openjdk 20"

let versionPath = joinPath(getEnv("HOME"), ".jpvm", "jdks", "versions.json")

proc onProgressChanged(total, progress, speed: BiggestInt) {.async.} =
  echo "Downloaded " & formatFloat(progress / 1000 / 1000, ffDecimal,
      2) & "MB of " & formatFloat(total / 1000 / 1000, ffDecimal, 2) & "MB"
  echo "Current rate: " & $(speed / 1000) & "kb/s"

proc httpDownload(url, fileName: string) {.async.} =
  let ua = r"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.835.163 Safari/535.1"
  var client = newAsyncHttpClient(userAgent = ua)
  client.onProgressChanged = onProgressChanged
  await client.downloadFile(url, fileName)
  echo "File finished downloading"


proc downloadVersionList() =
  var url = "https://gitee.com/monkeyNaive/jpvm/raw/master/versions.json"
  var dirPath = joinPath(getEnv("HOME"), ".jpvm", "jdks")
  if dirExists(dirPath):
    echo "下载JDK版本信息: " & url
    waitFor httpDownload(url, joinPath(dirPath, "versions.json"))
    echo "下载JDK版本信息完成"
  else:
    createDir(dirPath)
    downloadVersionList()

proc sysOS(): string =
  when defined windows:
    return "windows"
  elif defined linux:
    return "linux"
  else:
    return "macos"

proc sysArch(): string =
  when defined x86:
    return "x86"
  elif defined amd64:
    return "amd64"
  else:
    return "aarch64"

proc downloadCache(distro: string, version: string, sys: string, arch: string,
    json: JsonNode): (string, string) =
  var cachePath = joinPath(getEnv("HOME"), ".jpvm", "cache", "jdks", distro)
  if not dirExists(cachePath):
    createDir(cachePath)
  try:
    var url = json[distro][version][sys][arch]
    var (_, tail) = splitPath(url.getStr())
    echo "Download from " & url.getStr()
    var packagePath = joinPath(cachePath, tail)
    var (parentDir, packageName, ext) = splitFile(packagePath)
    if not fileExists(packagePath):
      waitFor httpDownload(url.getStr(), packagePath)
      echo "Download Over, Unzipping the package"
    else:
      echo "Find Cache, Unzipping the package"
    packageName = distro & "-" & version
    var packageDirPath = joinPath(parentDir, packageName)
    if dirExists(packageDirPath):
      removeDir(packageDirPath)
    if ext == ".zip":
      ziparchives.extractAll(packagePath, packageDirPath)
    else:
      tarballs.extractAll(packagePath, packageDirPath)
    var finalDir = ""
    for (k, p) in walkDir(packageDirPath):
      if k == pcDir:
        if p == "bin":
          finalDir = packageDirPath
        else:
          finalDir = p
    return (finalDir, packageName)
  except KeyError:
    echo "找不到要安装的版本"
    quit(0)

proc writeLinuxProfile(path: string) =
  var profilePath = joinPath(getEnv("HOME"), ".bash_profile")
  var info = "export JAVA_HOME=" & path
  var pathValue = "export PATH=$PATH:$JAVA_HOME/bin"
  var f = open(profilePath, fmAppend)
  f.writeLine(info)
  f.writeLine(pathValue)
  f.close()
  echo "运行: source ~/.bash_profile 使配置生效"

proc writeWindowsProfile(path: string) =
  discard execCmd("cmd /c setx JAVA_HOME " & path)
  echo r"JAVA_HOME已设置, 请将 %JAVA_HOME%\bin 添加到 Path 环境变量中"

proc writeProfile(path: string) =
  when defined windows:
    writeWindowsProfile(path)
  else:
    writeLinuxProfile(path)

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
  var dirPath = joinPath(getEnv("HOME"), ".jpvm", "jdks", distro, version, sys, arch)
  if not dirExists(dirPath):
    createDir(dirPath)
  var p = joinPath(dirPath, packageName)
  moveDir(packageDirPath, p)
  writeProfile(p)


proc installCommand*(): Command =
  var commandLine = CommandLine(
    mainArgument: "install",
    optArguments: @["distro", "version"]
  )
  Command(
      helpInfo: INSTALL_HELP_INFO,
      commandLine: commandLine,
      commandProc: installProc
  )
