package com.sonsofcrypto.web3lib.utils.extensions

fun String.isHexString(): Boolean {
    return this.length > 1 && Regex("^0x[0-9A-Fa-f]*\$").matches(this)
}

fun String.stripLeadingWhiteSpace(): String {
    var stripped = this
    listOf(" ", "\t", "\n")
        .forEach { stripped = stripped.replaceFirst(it, "")  }
    return stripped
}