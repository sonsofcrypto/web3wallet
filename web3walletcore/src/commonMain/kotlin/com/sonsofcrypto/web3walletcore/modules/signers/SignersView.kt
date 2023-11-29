package com.sonsofcrypto.web3walletcore.modules.signers

interface SignersView {
    fun update(viewModel: SignersViewModel)
    fun updateTargetView(targetView: SignersViewModel.TransitionTargetView)
    fun updateCTASheet(expanded: Boolean)
}