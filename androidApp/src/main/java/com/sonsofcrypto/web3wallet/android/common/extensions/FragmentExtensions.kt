package com.sonsofcrypto.web3wallet.android.common.extensions

import androidx.fragment.app.Fragment

fun Fragment.drawableResource(name: String): Int = resources.getIdentifier(
    name, "drawable", context?.packageName
)