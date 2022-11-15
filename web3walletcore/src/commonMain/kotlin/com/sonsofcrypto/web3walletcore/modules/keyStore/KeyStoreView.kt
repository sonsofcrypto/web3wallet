package com.sonsofcrypto.web3walletcore.modules.keyStore

interface KeyStoreView {
    fun update(viewModel: KeyStoreViewModel)
    fun updateTargetView(targetView: KeyStoreViewModel.TransitionTargetView)
}