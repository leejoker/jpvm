#[
  Usage: jpvm [install|distro...] [--local] [distro] [version] 
  install [distro] [version]    不指定distro或者version的话默认安装最新的LTS版本, 例如： jpvm install openjdk 20
  distro                        列出所有的发行商
  list [distro]                 列出所有发行商jdk版本
      --local                   列出本地版本
  uninstall [distro] [version]  卸载指定版本
  use [distro] [version]        将指定版本作为当前环境变量
  clean                         清理下载缓存
  reset                         清理当前环境变量设置
]#
import cmd
import install_jdk

proc commandLines(): Cmder =
  var commands = @[installCommand()]
  registerCommands("jpvm [install|distro...] [--local] [distro] [version]", commands)

proc main() =
  var cmder = commandLines()
  cmder.helpInfo()

when isMainModule:
  main()
