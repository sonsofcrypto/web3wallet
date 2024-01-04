package com.sonsofcrypto.web3walletcore.modules.degen

import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ToastViewModel

interface DegenView {
    fun update(viewModel: DegenViewModel)
    fun presentAlert(viewModel: AlertViewModel)
    fun presentToast(viewModel: ToastViewModel)
    fun popToRootAndRefresh()
}
