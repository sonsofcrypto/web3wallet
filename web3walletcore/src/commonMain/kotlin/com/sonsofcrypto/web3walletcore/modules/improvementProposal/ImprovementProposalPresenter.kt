package com.sonsofcrypto.web3walletcore.modules.improvementProposal

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.services.improvementProposals.ImprovementProposal

sealed class ImprovementProposalPresenterEvent {
    data class Vote(val id: String): ImprovementProposalPresenterEvent()
    object Dismiss: ImprovementProposalPresenterEvent()
}

interface ImprovementProposalPresenter {
    fun present()
    fun handle(event: ImprovementProposalPresenterEvent)
}

class DefaultImprovementProposalPresenter(
    private val view: WeakRef<ImprovementProposalView>,
    private val wireframe: ImprovementProposalWireframe,
    private val context: ImprovementProposalContext,
): ImprovementProposalPresenter {
    private var selectedIdx = context.proposals.indexOf(context.proposal)

    override fun present() {
        updateView()
    }

    override fun handle(event: ImprovementProposalPresenterEvent) =
        when (event) {
            is ImprovementProposalPresenterEvent.Vote -> wireframe.navigate(
                ImprovementProposalWireframeDestination.Vote(proposal(event.id))
            )
            is ImprovementProposalPresenterEvent.Dismiss -> wireframe.dismiss()
        }

    private fun updateView() {
        view.get()?.update(viewModel())
    }

    private fun viewModel(): ImprovementProposalViewModel {
        return ImprovementProposalViewModel(
            Localized("proposal.title"),
            proposals(),
            selectedIdx
        )
    }

    private fun proposal(id: String): ImprovementProposal =
        context.proposals.first { it.id == id }

    private fun proposals(): List<ImprovementProposalViewModel.Details> =
        context.proposals.map {
            ImprovementProposalViewModel.Details(
                it.id,
                it.title,
                it.imageUrl,
                it.category.string + " | " + Localized("proposal.hashTag", it.id),
                ImprovementProposalViewModel.Summary(
                    Localized("proposal.summary.header"),
                    it.body
                ),
                Localized("proposal.button.vote")
            )
        }
}
