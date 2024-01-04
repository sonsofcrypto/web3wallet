package com.sonsofcrypto.web3walletcore.modules.nftDetail

import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel

interface NFTDetailView {
    fun update(viewModel: NFTDetailViewModel)
    fun presentAlert(viewModel: AlertViewModel)
}
