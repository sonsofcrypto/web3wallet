package com.sonsofcrypto.web3wallet.android.common.extensions

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.NavigationFragment
import com.sonsofcrypto.web3walletcore.app.App

val Fragment?.navigationFragment: NavigationFragment? get() = this as? NavigationFragment

fun Fragment.drawableId(
    name: String,
    defaultId: Int = R.drawable.icon_unknown
): Int = App.activity.drawableId(name = name, defaultId = defaultId)