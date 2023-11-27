package com.sonsofcrypto.web3walletcore.modules.mnemonicNew

import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ToastViewModel

interface MnemonicNewView {
    fun update(viewModel: CollectionViewModel.Screen)
    fun presentAlert(viewModel: AlertViewModel)
    fun presentToast(viewModel: ToastViewModel)
}
