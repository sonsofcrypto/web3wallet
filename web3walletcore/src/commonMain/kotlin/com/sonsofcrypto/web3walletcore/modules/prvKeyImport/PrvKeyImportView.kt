package com.sonsofcrypto.web3walletcore.modules.prvKeyImport

import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ToastViewModel

interface PrvKeyImportView {
    fun update(
        viewModel: CollectionViewModel.Screen,
        inputViewModel: PrvKeyInputViewModel,
    )
    fun presentAlert(viewModel: AlertViewModel)
    fun presentToast(viewModel: ToastViewModel)
    fun scrollToBottom()
}

data class PrvKeyInputViewModel(
    val isValid: Boolean,
    val err: PrvKeyImportError?
)
