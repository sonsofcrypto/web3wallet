package com.sonsofcrypto.web3lib.utils.extensions

fun String.isHexString(): Boolean {
    return this.length > 1 && Regex("^0x[0-9A-Fa-f]*\$").matches(this)
}