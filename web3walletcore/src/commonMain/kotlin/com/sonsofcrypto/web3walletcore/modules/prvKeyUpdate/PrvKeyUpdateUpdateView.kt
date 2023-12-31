package com.sonsofcrypto.web3walletcore.modules.prvKeyUpdate

import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ToastViewModel

interface PrvKeyUpdateView {
    fun update(viewModel: CollectionViewModel.Screen)
    fun presentAlert(viewModel: AlertViewModel)
    fun presentToast(viewModel: ToastViewModel)
    fun scrollToBottom()
}
