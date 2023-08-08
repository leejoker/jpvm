# Java Platform Version Manager(施工中)

专为中国 Javaer 开发的 Java 平台开发环境初始化工具，用来方便的管理、安装 JDK 以及相关 JVM 平台组件

使用国内源，确保安装速度

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
nimble build -d:ssl

```

## 使用方法

```shell
./jpvm install openjdk 17

```

## 鸣谢

感谢 JDK 分发支持： [Java I tell you](https://www.injdk.cn/)
