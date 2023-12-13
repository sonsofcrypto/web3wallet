package com.sonsofcrypto.web3walletcore.modules.signers

import com.sonsofcrypto.web3walletcore.common.viewModels.ToastViewModel

interface SignersView {
    fun update(viewModel: SignersViewModel)
    fun updateTargetView(targetView: SignersViewModel.TransitionTargetView)
    fun updateCTASheet(expanded: Boolean)
    fun presentToast(viewModel: ToastViewModel)
}