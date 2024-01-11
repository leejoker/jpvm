import strutils, asyncdispatch, httpclient, zippy/ziparchives, zippy/tarballs,
    os, registry, sequtils, global, strformat

var printMessage = true

proc onProgressChanged*(total, progress, speed: BiggestInt) {.async.} =
  if printMessage: echo "Downloaded " & formatFloat(progress / 1000 / 1000,
      ffDecimal, 2) & "MB of " & formatFloat(total / 1000 / 1000, ffDecimal,
          2) & "MB"
  if printMessage: echo "Current rate: " & $(speed / 1000) & "kb/s"

proc httpDownload*(url, fileName: string) {.async.} =
  let ua = r"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.835.163 Safari/535.1"
  var client = newAsyncHttpClient(userAgent = ua)
  client.onProgressChanged = onProgressChanged
  await client.downloadFile(url, fileName)
  if printMessage: echo "File finished downloading"

proc unzipFiles*(src: string, dest: string) =
  var (_, _, ext) = splitFile(src)
  if dirExists(dest):
    removeDir(dest)
  if ext == ".zip":
    ziparchives.extractAll(src, dest)
  else:
    tarballs.extractAll(src, dest)

proc createDirs*(path: string) =
  if not dirExists(path):
    createDir(path)

proc createDirs*(args: varargs[string]): string =
  var path = joinPath(args)
  createDirs(path)
  return path

proc findBinDir*(path: string): string =
  var binDir = ""
  for (k, p) in walkDir(path):
    if k == pcDir:
      if p == "bin":
        binDir = path
      else:
        binDir = p
  return binDir

proc sysOS*(): string =
  when defined windows:
    return "windows"
  elif defined linux:
    return "linux"
  else:
    return "macos"

proc sysArch*(): string =
  when defined x86:
    return "x86"
  elif defined amd64:
    return "amd64"
  else:
    return "aarch64"

proc newLine*(): string =
  when defined windows:
    return "\r\n"
  elif defined linux:
    return "\n"
  else:
    return "\n"


proc writeUnixProfile*(key: string, value: string) =
  var profileName = ".bash_profile"
  var profilePath = joinPath(getEnv("HOME"), profileName)
  if not fileExists(profilePath):
    profileName = ".bashrc"
    if fileExists(joinPath(getEnv("HOME"), profileName)):
      profilePath = joinPath(getEnv("HOME"), profileName)
    else:
      profileName = ".profile"
      profilePath = joinPath(getEnv("HOME"), profileName)
  if defined osx:
    profileName = ".zshrc"
    if fileExists(joinPath(getEnv("HOME"), profileName)):
      profilePath = joinPath(getEnv("HOME"), profileName)
  var content = readFile(profilePath)
  var lines = splitLines(content, false)
  var hasKey = false
  var hasPathKey = false
  var index = 0
  var pathIndex = 0
  var envInfo = "export " & key & "=" & value
  var toWriteInfo = "$" & key & "/bin"
  var pathValue = "export PATH=" & toWriteInfo & ":$PATH"

  for i, line in lines:
    if line.startsWith("export " & key):
      hasKey = true
      index = i
    if line.startsWith("export PATH="):
      hasPathKey = true
      pathIndex = i

  if hasKey:
    lines[index] = envInfo
  else:
    if not hasPathKey:
      lines.add(envInfo)
    else:
      lines.insert(@[envInfo], pathIndex)
      pathIndex = pathIndex + 1

  if not hasPathKey:
    lines.add(pathValue)
  else:
    if not lines[pathIndex].contains(toWriteInfo):
      lines[pathIndex] = "export PATH=" & toWriteInfo & ":" & lines[
          pathIndex].split("=")[1]

  var f = open(profilePath, fmWrite)
  for line in lines:
    f.writeLine(line)
  f.close()
  echo "运行: source ~/" & profileName & " 使配置生效"

proc writeWindowsProfile(key: string, value: string) =
  var originValue = getUnicodeValue("Environment", key, HKEY_CURRENT_USER)
  setUnicodeValue("Environment", key, value, HKEY_CURRENT_USER)
  var path = getUnicodeValue(r"Environment", "Path", HKEY_CURRENT_USER)
  if path.contains(originValue & r"\bin"):
    path = path.replace(originValue & r"\bin", "")
  var pathArray = path.split(";").filter do (x: string) -> bool: x != ""
  var toWriteInfo = value & r"\bin"
  if not path.contains(toWriteInfo):
    pathArray.add(toWriteInfo)
    path = pathArray.join(";")
    setUnicodeValue("Environment", "Path", path, HKEY_CURRENT_USER)
    echo "环境变量修改完成，重新打开控制台生效"
  else:
    echo "环境变量已存在"

proc writeProfile*(key: string, value: string) =
  when defined windows:
    writeWindowsProfile(key, value)
  else:
    writeUnixProfile(key, value)

proc moveJpvmDir*(src: string, dest: string) =
  if dirExists(dest):
    removeDir(dest)
  moveDir(src, dest)

proc downloadVersionList*(pm: bool = true) =
  var url = "https://gitee.com/monkeyNaive/jpvm/raw/master/versions.json"
  printMessage = pm
  if dirExists(jdkPath):
    if printMessage: echo "下载JDK版本信息: " & url
    waitFor httpDownload(url, versionPath)
    if printMessage: echo "下载JDK版本信息完成"
  else:
    createDir(jdkPath)
    downloadVersionList()

proc jdkVersionPath*(args: seq[string]): (string, string, string) =
  var distro: string
  var version: string
  if len(args) != 0:
    if args[0] != "":
      distro = args[0]
    else:
      echo "请指定发行版信息"
      return
    if len(args) > 1 and args[1] != "":
      version = args[1]
    else:
      echo "请指定版本"
      return
  else:
    echo "请指定发行版和版本号"
    return
  var arch = sysArch()
  var sys = sysOS()
  var dirPath = createDirs(jdkPath, distro, version, sys, arch)
  var packageName = distro & "-" & version
  if dirExists(joinPath(dirPath, packageName)):
    var path = joinPath(dirPath, packageName)
    return (distro, version, path)
  else:
    echo fmt"指定版本 {distro}-{version} 不存在"
    return (distro, version, "")
