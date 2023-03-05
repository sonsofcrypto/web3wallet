package com.sonsofcrypto.web3wallet.android.common

import com.sonsofcrypto.web3lib.utils.BigInt
import java.util.*

val String.firstLetterCapital: String get() = replaceFirstChar {
    if (it.isLowerCase())
        it.titlecase(Locale.getDefault())
    else it.toString()
}

fun String?.toBigInt(decimals: UInt): BigInt {
    val text = this ?: return BigInt.zero
    if (text.isEmpty()) return BigInt.zero
    try {
        val currentDecimals = text.decimals
        if (currentDecimals == null) {
            val fullDecimals = "".addRemainingDecimals(decimals)
            return BigInt.from(text.trimFinalDotIfNeeded + fullDecimals)
        }
        val numberWithoutDecimals = text.split(".")[0]
        val fullDecimals = currentDecimals.addRemainingDecimals(decimals)
        return BigInt.from(numberWithoutDecimals + fullDecimals)
    } catch (e: Exception) {
        return BigInt.zero
    }
}

private fun String.addRemainingDecimals(upTo: UInt): String {
    val missingDecimals = upTo.toInt() - count()
    if (missingDecimals <= 0) return this
    var toReturn = this
    for (i in 0 until missingDecimals) {
        toReturn += "0"
    }
    return toReturn
}

val String.nonDecimals: String get() = split(".")[0]

val String.decimals: String? get() {
    val split = split(".")
    if (split.count() != 2) { return null }
    return split[1]
}

private val String.trimFinalDotIfNeeded: String get() = if (last() == '.') {
    dropLast(1)
} else {
    this
}
