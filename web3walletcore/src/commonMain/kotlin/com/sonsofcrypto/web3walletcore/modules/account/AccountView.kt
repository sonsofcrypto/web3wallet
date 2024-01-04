package com.sonsofcrypto.web3walletcore.modules.account

import com.sonsofcrypto.web3walletcore.common.viewModels.AlertViewModel

interface AccountView {
    fun update(viewModel: AccountViewModel)
    fun presentAlert(viewModel: AlertViewModel)
}
