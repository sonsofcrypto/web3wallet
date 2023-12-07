package com.sonsofcrypto.web3lib.utils

import com.sonsofcrypto.web3lib.utils.extensions.subListTo

fun defaultDerivationPath(): String
    = "m/44'/60'/0'/0/0"

fun lastDerivationPathComponent(path: String): Int
    = path.split("/").last().toInt()

fun incrementedDerivationPath(path: String): String {
    val splitPath = path.split("/")
    val nextIdx = splitPath.last().toInt() + 1
    return (splitPath.dropLast(1) + nextIdx.toString()).joinToString("/")
}

@OptIn(ExperimentalStdlibApi::class)
fun isValidDerivationPath(path: String): Boolean {
    if(path.substring(0..<2) != "m/") return false
    path.replace("m/", "").split("/").forEach {
        if (it.count { it.toString() == "'" } > 1)
            return false
        if (it.contains("."))
            return false
        for (char in it.replace("'", "")) {
            if (!char.isDigit()) return false
        }
    }
    return true
}