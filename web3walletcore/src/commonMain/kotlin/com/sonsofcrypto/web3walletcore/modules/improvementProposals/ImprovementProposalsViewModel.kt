package com.sonsofcrypto.web3walletcore.modules.improvementProposals

import com.sonsofcrypto.web3walletcore.common.viewModels.CommonErrorViewModel
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.services.ImprovmentProposals.ImprovementProposal
import com.sonsofcrypto.web3walletcore.services.ImprovmentProposals.ImprovementProposal.Category.*

sealed class ImprovementProposalsViewModel {
    /** Loading proposals */
    object Loading: ImprovementProposalsViewModel()
    /** Successfully fetched proposals */
    data class Loaded(
        val sections: List<Section>,
        val selectedIdx: Int
    ): ImprovementProposalsViewModel()
    /** Error occurred */
    data class Error(
        val error: CommonErrorViewModel
    ): ImprovementProposalsViewModel()

    data class Section(
        val title: String,
        val description: String,
        val items: List<Item>
    )

    data class Item(
        val id: String,
        val title: String,
        val subtitle: String,
    )

    companion object
}

fun ImprovementProposalsViewModel.Companion.title(
    category: ImprovementProposal.Category
): String = when (category) {
    INTEGRATION -> Localized("proposals.infrastructure.title")
    INFRASTRUCTURE -> Localized("proposals.integrations.title")
    FEATURE -> Localized("proposals.features.title")
    UNKNOWN -> Localized("proposals.unknown.title")
} + " " + Localized("proposals")

fun ImprovementProposalsViewModel.Companion.description(
    category: ImprovementProposal.Category
): String = when (category) {
    INTEGRATION -> Localized("proposals.infrastructure.description")
    INFRASTRUCTURE -> Localized("proposals.integrations.description")
    FEATURE -> Localized("proposals.features.description")
    UNKNOWN -> ""
}
