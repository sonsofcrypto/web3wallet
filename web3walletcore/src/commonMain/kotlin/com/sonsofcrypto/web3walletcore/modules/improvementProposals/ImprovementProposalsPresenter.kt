package com.sonsofcrypto.web3walletcore.modules.improvementProposals

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3lib.utils.withUICxt
import com.sonsofcrypto.web3walletcore.common.viewModels.CommonErrorViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.with
import com.sonsofcrypto.web3walletcore.extensions.LocalizedFmt
import com.sonsofcrypto.web3walletcore.modules.improvementProposals.ImprovementProposalsViewModel.*
import com.sonsofcrypto.web3walletcore.modules.improvementProposals.ImprovementProposalsWireframeDestination.*
import com.sonsofcrypto.web3walletcore.services.ImprovmentProposals.ImprovementProposal
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

sealed class ImprovementProposalsPresenterEvent {
    data class Category(val idx: Int): ImprovementProposalsPresenterEvent()
    data class Vote(val idx: Int): ImprovementProposalsPresenterEvent()
    data class Proposal(val idx: Int): ImprovementProposalsPresenterEvent()
    object Dismiss: ImprovementProposalsPresenterEvent()
}

interface ImprovementProposalsPresenter {
    fun present()
    fun handle(event: ImprovementProposalsPresenterEvent)
}

class DefaultImprovementProposalsPresenter(
    private val view: WeakRef<ImprovementProposalsView>,
    private val interactor: ImprovementProposalsInteractor,
    private val wireframe: ImprovementProposalWireframe
) : ImprovementProposalsPresenter {
    private var proposals: List<ImprovementProposal> = emptyList()
    private var error: Throwable? = null
    private var selectedCategoryIdx: Int = 0
    private val scope = CoroutineScope(bgDispatcher)

    override fun present() {
        updateView()
        val errHandler = CoroutineExceptionHandler { _, err ->
            error = err
            println(err)
        }
        scope.launch(errHandler) {
            val result = interactor.fetchProposals()
            withUICxt {
                proposals = result
                updateView()
            }
        }
    }

    override fun handle(event: ImprovementProposalsPresenterEvent) {
        when (event) {
            is ImprovementProposalsPresenterEvent.Category -> {
                selectedCategoryIdx = event.idx
                updateView()
            }
            is ImprovementProposalsPresenterEvent.Vote -> wireframe.navigate(
                Vote(proposalAt(event.idx))
            )
            is ImprovementProposalsPresenterEvent.Proposal -> wireframe.navigate(
                Proposal(proposalAt(event.idx), proposals(selectedCategoryIdx))
            )
            is ImprovementProposalsPresenterEvent.Dismiss -> wireframe.navigate(
                Dismiss
            )
        }
    }

    private fun updateView() = view.get()?.update(viewModel())

    private fun viewModel(): ImprovementProposalsViewModel {
        if (error != null)
            return Error(CommonErrorViewModel.with(error!!))
        if (proposals.isEmpty())
            return Loading
        return Loaded(
            ImprovementProposal.Category.values().map { category ->
                Section(
                    ImprovementProposalsViewModel.title(category),
                    ImprovementProposalsViewModel.description(category),
                    proposals.filter { it.category == category }
                        .map { Item(it.id, it.title, proposalSubtitle(it)) }
                )
            },
            selectedCategoryIdx
        )
    }

    private fun proposalAt(idx: Int): ImprovementProposal {
        return proposals(selectedCategoryIdx)[idx]
    }

    private fun proposals(categoryIdx: Int): List<ImprovementProposal> {
        val category = ImprovementProposal.Category.values()[categoryIdx]
        return proposals.filter { it.category == category }
    }

    private fun proposalSubtitle(proposal: ImprovementProposal): String {
        return LocalizedFmt("proposal.hashTag", proposal.id) + "  |  " +
            LocalizedFmt("proposals.votes", proposal.votes)
    }
}