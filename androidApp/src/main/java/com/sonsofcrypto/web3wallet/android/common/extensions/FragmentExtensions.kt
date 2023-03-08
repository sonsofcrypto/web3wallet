package com.sonsofcrypto.web3wallet.android.common.extensions

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3wallet.android.common.NavigationFragment

fun Fragment.drawableResource(name: String): Int = resources.getIdentifier(
    name, "drawable", context?.packageName
)

val Fragment?.navigationFragment: NavigationFragment? get() = this as? NavigationFragment