package com.sonsofcrypto.web3walletcore.modules.accountImport

import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ToastViewModel

interface AccountImportView {
    fun update(
        viewModel: CollectionViewModel.Screen,
        inputViewModel: AccountImportInputViewModel,
    )
    fun presentAlert(viewModel: AlertViewModel)
    fun presentToast(viewModel: ToastViewModel)
    fun scrollToBottom()
}

data class AccountImportInputViewModel(
    val key: String,
    val isValid: Boolean,
    val err: AccountImportError?
)
