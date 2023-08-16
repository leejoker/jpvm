import os

let versionPath* = joinPath(getEnv("HOME"), ".jpvm", "jdks", "versions.json")
let jdkPath* = joinPath(getEnv("HOME"), ".jpvm", "jdks")
let cachePath* = joinPath(getEnv("HOME"), ".jpvm", "cache")
