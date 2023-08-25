import os

let basePath* = joinPath(getEnv("HOME"), ".jpvm")
let versionPath* = joinPath(basePath, "jdks", "versions.json")
let jdkPath* = joinPath(basePath, "jdks")
let cachePath* = joinPath(basePath, "cache")
let curVersionPath* = joinPath(basePath, ".jdk_version")
