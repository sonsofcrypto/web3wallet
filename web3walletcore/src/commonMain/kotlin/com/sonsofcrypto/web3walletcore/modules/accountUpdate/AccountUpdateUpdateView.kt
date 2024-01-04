package com.sonsofcrypto.web3walletcore.modules.accountUpdate

import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ToastViewModel

interface AccountUpdateView {
    fun update(viewModel: CollectionViewModel.Screen)
    fun presentAlert(viewModel: AlertViewModel)
    fun presentToast(viewModel: ToastViewModel)
    fun scrollToBottom()
}
