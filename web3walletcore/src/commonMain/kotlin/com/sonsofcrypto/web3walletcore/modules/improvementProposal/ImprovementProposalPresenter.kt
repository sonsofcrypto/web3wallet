package com.sonsofcrypto.web3walletcore.modules.improvementProposal

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.improvementProposal.ImprovementProposalWireframeDestination.Dismiss
import com.sonsofcrypto.web3walletcore.modules.improvementProposal.ImprovementProposalWireframeDestination.Vote
import com.sonsofcrypto.web3walletcore.services.improvementProposals.ImprovementProposal

sealed class ImprovementProposalPresenterEvent {
    data class Vote(val idx: Int): ImprovementProposalPresenterEvent()
    object Dismiss: ImprovementProposalPresenterEvent()
}

interface ImprovementProposalPresenter {
    fun present()
    fun handle(event: ImprovementProposalPresenterEvent)
}

class DefaultImprovementProposalPresenter(
    private val view: WeakRef<ImprovementProposalView>,
    private val wireframe: ImprovementProposalWireframe,
    private val proposals: List<ImprovementProposal>,
    private var selectedIdx: Int,
): ImprovementProposalPresenter {

    override fun present() {
        updateView()
    }

    override fun handle(event: ImprovementProposalPresenterEvent) =
        when (event) {
            is ImprovementProposalPresenterEvent.Vote -> wireframe.navigate(
                Vote(proposals[event.idx])
            )
            is ImprovementProposalPresenterEvent.Dismiss -> wireframe.navigate(
                Dismiss
            )
        }

    private fun updateView() = view.get()?.update(viewModel())

    private fun viewModel(): ImprovementProposalViewModel =
        ImprovementProposalViewModel(proposals(), selectedIdx)

    private fun proposals(): List<ImprovementProposalViewModel.Proposal> =
        proposals.map {
            ImprovementProposalViewModel.Proposal(
                it.id,
                it.title,
                it.imageUrl,
                it.category.string + " | " + Localized("proposal.hashTag", it.id),
                it.body,
            )
        }
}
