# Java Platform Version Manager

专为中国 Javaer 开发的 Java 平台开发环境初始化工具，用来方便的管理、安装 JDK 以及相关 JVM 平台组件

使用国内源，确保安装速度

## 1.0.0 功能

- [x] 安装JDK
- [x] 查看发行版信息
- [x] 查看所有发行版和版本
- [x] 清理缓存
- [x] 设置使用的版本
 
## 构建方法

### 安装 nim

```shell
# 使用choosenim 进行安装
curl https://nim-lang.org/choosenim/init.sh -sSf | sh

```

### 构建

```shell
git clone https://gitee.com/monkeyNaive/jpvm.git
cd jpvm
nimble build -d:ssl -d:release

```

## 使用方法

### 安装JDK

```shell
./jpvm install openjdk 17

```

### 查看帮助信息

```shell
./jpvm

Usage: jpvm [install|distro...] [--local] [distro] [version]

install [distro] [version]    不指定distro或者version的话默认安装OpenJDK最新的LTS版本, 例如： jpvm install openjdk 20
clean                         清理缓存目录
distro                        查看支持的发行版
list [--local]                查看所有发行版，增加 --local 参数后，查看已安装的发行版
use {distro} {version}        使用指定版本, 例如: jpvm use openjdk 17
current                       获取当前使用的JDK版本
remove [distro] [version]     移除指定版本
```

## 鸣谢

感谢 JDK 分发支持： [Java I tell you](https://www.injdk.cn/)
