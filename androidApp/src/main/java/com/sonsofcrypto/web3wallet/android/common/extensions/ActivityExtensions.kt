package com.sonsofcrypto.web3wallet.android.common.extensions

import android.app.Activity
import android.content.res.Resources
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3walletcore.app.App

fun Activity?.drawableId(name: String, defaultId: Int = R.drawable.icon_unknown): Int {
    val resources = this?.resources ?: return defaultId
    val id = resources.getIdentifier(
        name.replace("-", "_"), "drawable", App.Companion.context.packageName
    )
    return if (id == Resources.ID_NULL) defaultId else id
}

