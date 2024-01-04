package com.sonsofcrypto.web3walletcore.modules.dashboard

import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel

interface DashboardView {
    fun update(viewModel: DashboardViewModel)
    fun presentAlert(viewModel: AlertViewModel)
}
