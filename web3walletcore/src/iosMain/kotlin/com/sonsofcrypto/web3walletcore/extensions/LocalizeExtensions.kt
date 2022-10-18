package com.sonsofcrypto.web3walletcore.extensions

import platform.Foundation.NSBundle
import platform.Foundation.NSString
import platform.Foundation.stringWithFormat

actual fun Localized(string: String): String {
    return NSBundle.mainBundle.localizedStringForKey(string, null, null)
}

actual fun Localized(fmt: String, vararg args: Any?): String {
    return when (args.size) {
        0 -> NSString.stringWithFormat(Localized(fmt))
        1 -> NSString.stringWithFormat(Localized(fmt), args[0])
        2 -> NSString.stringWithFormat(Localized(fmt), args[0], args[1])
        3 -> NSString.stringWithFormat(Localized(fmt), args[0], args[1], args[2])
        4 -> NSString.stringWithFormat(Localized(fmt), args[0], args[1], args[2], args[3])
        5 -> NSString.stringWithFormat(Localized(fmt), args[0], args[1], args[2], args[3], args[4])
        6 -> NSString.stringWithFormat(Localized(fmt), args[0], args[1], args[2], args[3], args[4], args[5])
        7 -> NSString.stringWithFormat(Localized(fmt), args[0], args[1], args[2], args[3], args[4], args[5], args[6])
        8 -> NSString.stringWithFormat(Localized(fmt), args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7])
        9 -> NSString.stringWithFormat(Localized(fmt), args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
        10 -> NSString.stringWithFormat(Localized(fmt), args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9])
        else -> throw IllegalStateException("ios String.format() can only accept up to 10 arguments")
    }
}

// NOTE: This is ugly hack due to KMM inability to pass varargs to ObjC
