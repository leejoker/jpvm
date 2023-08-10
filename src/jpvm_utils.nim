import strutils, asyncdispatch, httpclient, zippy/ziparchives, zippy/tarballs,
    os, registry

proc onProgressChanged*(total, progress, speed: BiggestInt) {.async.} =
  echo "Downloaded " & formatFloat(progress / 1000 / 1000, ffDecimal,
      2) & "MB of " & formatFloat(total / 1000 / 1000, ffDecimal, 2) & "MB"
  echo "Current rate: " & $(speed / 1000) & "kb/s"

proc httpDownload*(url, fileName: string) {.async.} =
  let ua = r"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.835.163 Safari/535.1"
  var client = newAsyncHttpClient(userAgent = ua)
  client.onProgressChanged = onProgressChanged
  await client.downloadFile(url, fileName)
  echo "File finished downloading"

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


proc writeLinuxProfile*(key: string, value: string) =
  var profilePath = joinPath(getEnv("HOME"), ".bash_profile")
  var content = readFile(profilePath)
  var f = open(profilePath, fmAppend)
  var envInfo = "export " & key & "=" & value
  var toWriteInfo = "$" & key & "/bin"
  if not content.contains(envInfo):
    f.writeLine(envInfo)
  if not content.contains(toWriteInfo):
    var pathValue = "export PATH=$PATH:" & toWriteInfo
    f.writeLine(pathValue)
  f.close()
  echo "运行: source ~/.bash_profile 使配置生效"

proc writeWindowsProfile(key: string, value: string) =
  setUnicodeValue("Environment", key, value, HKEY_CURRENT_USER)
  var path = getUnicodeValue(r"Environment", "Path", HKEY_CURRENT_USER)
  var toWriteInfo = "%" & key & r"%\bin"
  if not path.contains(toWriteInfo):
    path = path & ";" & toWriteInfo
    setUnicodeValue("Environment", "Path", path, HKEY_CURRENT_USER)
    echo "环境变量修改完成，重新打开控制台生效"
  else:
    echo "环境变量已存在"

proc writeProfile*(key: string, value: string) =
  when defined windows:
    writeWindowsProfile(key, value)
  else:
    writeLinuxProfile(key, value)
