package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.NavigationFragment
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment

val WeakRef<Fragment>?.navigationFragment: NavigationFragment? get() = this?.get()?.navigationFragment