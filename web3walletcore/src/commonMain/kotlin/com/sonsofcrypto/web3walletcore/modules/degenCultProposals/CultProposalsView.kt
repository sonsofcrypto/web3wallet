package com.sonsofcrypto.web3walletcore.modules.degenCultProposals

import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ToastViewModel

interface CultProposalsView {
    fun update(viewModel: CultProposalsViewModel)
    fun presentAlert(viewModel: AlertViewModel)
    fun presentToast(viewModel: ToastViewModel)
}
