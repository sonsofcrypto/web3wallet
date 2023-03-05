package com.sonsofcrypto.web3wallet.android.common.extensions

import android.app.Activity
import com.sonsofcrypto.web3walletcore.extensions.App

fun Activity.drawableResource(name: String): Int = resources.getIdentifier(
    name.replace("-", "_"), "drawable", App.Companion.context.packageName
)