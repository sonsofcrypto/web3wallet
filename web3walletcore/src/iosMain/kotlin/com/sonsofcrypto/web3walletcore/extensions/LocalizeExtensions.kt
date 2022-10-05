package com.sonsofcrypto.web3walletcore.extensions

import platform.Foundation.*
import platform.darwin.NSObject

actual fun Localized(string: String): String {
    return NSBundle.mainBundle.localizedStringForKey(string, null, null)
}

actual fun LocalizedFmt(fmt: String, vararg params: Any): String {
    println("=== fmt $fmt | ${Localized(fmt)}")
    println("=== params $params")
    println("=== params mapped ${params.map { it as NSObject}}")
    val resutl =  NSString.stringWithFormat(
        Localized(fmt),
        params.map { it as NSObject }
    )
    println("=== result $resutl")
    return resutl
}
