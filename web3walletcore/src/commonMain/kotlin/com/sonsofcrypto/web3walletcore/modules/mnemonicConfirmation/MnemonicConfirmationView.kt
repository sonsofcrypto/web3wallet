package com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation

import com.sonsofcrypto.web3walletcore.common.helpers.MnemonicInputViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel

interface MnemonicConfirmationView {
    fun update(
        viewModel: CollectionViewModel.Screen,
        mnemonicInputViewModel: MnemonicInputViewModel
    )
}
