package com.sonsofcrypto.web3lib.utils

fun defaultDerivationPath(): String
    = "m/44'/60'/0'/0/0"

fun lastDerivationPathComponent(path: String): Int
    = path.split("/").last().toInt()

fun incrementedDerivationPath(path: String): String {
    val splitPath = path.split("/")
    val nextIdx = splitPath.last().toInt() + 1
    return (splitPath.dropLast(1) + nextIdx.toString()).joinToString("/")
}