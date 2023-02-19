package com.sonsofcrypto.web3wallet.android.modules.root

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.View
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3walletcore.modules.root.RootView

class RootFragment : Fragment(R.layout.root_fragment), RootView {

    lateinit var presenter: RootPresenter

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        presenter.present()
    }
}