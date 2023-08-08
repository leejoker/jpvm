import cmd, asyncdispatch, httpclient, os

const INSTALL_HELP_INFO = "install [distro] [version]    不指定distro或者version的话默认安装最新的LTS版本, 例如： jpvm install openjdk 20"

proc onProgressChanged(total, progress, speed: BiggestInt) {.async.} =
  echo("Downloaded ", progress, " of ", total)
  echo("Current rate: ", speed div 1000, "kb/s")

proc httpDownload(url, fileName: string) {.async.} =
  let ua = r"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.835.163 Safari/535.1"
  var client = newAsyncHttpClient(userAgent = ua)
  client.onProgressChanged = onProgressChanged
  await client.downloadFile(url, fileName)
  echo "File finished downloading"


# proc downloadVersionList(): bool =



proc installProc(command: CommandLine) =
  var distro = "latest"
  if len(command.optArguments) != 0 and command.optArguments[0] != "":
    distro = command.optArguments[0]
  var cachePath = joinPath(getEnv("HOME"), ".jpvm", "cache", "jdks", distro)
  var dirPath = joinPath(getEnv("HOME"), ".jpvm", "jdks", distro)
  if dirExists(cachePath):
    echo ""

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
