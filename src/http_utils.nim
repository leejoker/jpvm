import asyncdispatch, httpclient, strutils

const USER_AGENT = r"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.835.163 Safari/535.1"
var printMessage = true

proc httpGet*(url: string): string =
  var client = newAsyncHttpClient(userAgent = USER_AGENT)
  var response = waitFor client.get(url)
  if response.code() == Http200:
    return waitFor response.body()


proc onProgressChanged*(total, progress, speed: BiggestInt) {.async.} =
  if printMessage: echo "Downloaded " & formatFloat(progress / 1000 / 1000,
      ffDecimal, 2) & "MB of " & formatFloat(total / 1000 / 1000, ffDecimal,
          2) & "MB"
  if printMessage: echo "Current rate: " & $(speed / 1000) & "kb/s"

proc httpDownload*(url, fileName: string, pm: bool = true) {.async.} =
  printMessage = pm
  var client = newAsyncHttpClient(userAgent = USER_AGENT)
  client.onProgressChanged = onProgressChanged
  await client.downloadFile(url, fileName)
  if printMessage: echo "File finished downloading"
