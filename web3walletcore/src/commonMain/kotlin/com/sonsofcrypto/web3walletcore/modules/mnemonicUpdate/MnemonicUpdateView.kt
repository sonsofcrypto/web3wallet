package com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate

import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel
import com.sonsofcrypto.web3walletcore.modules.alert.AlertViewModelOld

interface MnemonicUpdateView {
    fun update(viewModel: CollectionViewModel.Screen)
    fun presentAlert(viewModel: AlertViewModelOld)
}
