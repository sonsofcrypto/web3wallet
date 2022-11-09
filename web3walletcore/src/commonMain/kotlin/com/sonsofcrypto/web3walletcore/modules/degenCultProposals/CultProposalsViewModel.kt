package com.sonsofcrypto.web3walletcore.modules.degenCultProposals

import com.sonsofcrypto.web3walletcore.common.viewModels.ErrorViewModel

sealed class CultProposalsViewModel {
    object Loading: CultProposalsViewModel()
    data class Loaded(val sections: List<Section>): CultProposalsViewModel()
    data class Error(val error: ErrorViewModel): CultProposalsViewModel()

    sealed class Section() {
        data class Pending(val title: String, val items: List<Item>, val footer: Footer): Section()
        data class Closed(val title: String, val items: List<Item>, val footer: Footer): Section()
    }

    data class Item(
        val id: String,
        val title: String,
        val approved: Vote,
        val rejected: Vote,
        val approveButtonTitle: String,
        val rejectButtonTitle: String,
        val endDate: Double,
        val stateName: String,
    )

    data class Vote(
        val name: String,
        val value: Double,
        val total : Double,
    )

    data class Footer(
        val imageName: String,
        val text: String,
    )
}
