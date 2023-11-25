package com.sonsofcrypto.web3walletcore.modules.mnemonicNew

import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel
import com.sonsofcrypto.web3walletcore.modules.alert.AlertViewModelOld

interface MnemonicNewView {
    fun update(viewModel: CollectionViewModel.Screen)
    fun presentAlert(viewModel: AlertViewModelOld)
}
