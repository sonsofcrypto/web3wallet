package com.sonsofcrypto.web3walletcore.extensions

import android.content.Context

fun Context.getStringResourceByName(stringName: String): String? {
    val resId = resources.getIdentifier(stringName, "string", packageName)
    return getString(resId)
}