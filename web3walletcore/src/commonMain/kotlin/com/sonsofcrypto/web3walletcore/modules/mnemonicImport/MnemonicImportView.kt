package com.sonsofcrypto.web3walletcore.modules.mnemonicImport

import com.sonsofcrypto.web3walletcore.common.helpers.MnemonicInputViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ToastViewModel

interface MnemonicImportView {
    fun update(
        viewModel: CollectionViewModel.Screen,
        mnemonicInputViewModel: MnemonicInputViewModel
    )
    fun presentAlert(viewModel: AlertViewModel)
    fun presentToast(viewModel: ToastViewModel)
    fun scrollToBottom()
}
