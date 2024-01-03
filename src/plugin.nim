# jpvm plugin
import cmd

type
    JpvmPlugin* = object of RootObj
        name* : string
        cmder: Cmder