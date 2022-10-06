package com.sonsofcrypto.web3walletcore.modules.improvementProposals

import com.sonsofcrypto.web3walletcore.services.improvementProposals.ImprovementProposal
import com.sonsofcrypto.web3walletcore.services.improvementProposals.ImprovementProposalsService

interface ImprovementProposalsInteractor {
    @Throws(Throwable::class)
    suspend fun fetchProposals(): List<ImprovementProposal>
}

class DefaultImprovementProposalsInteractor(
    private val improvementProposalsService: ImprovementProposalsService
): ImprovementProposalsInteractor {

    override suspend fun fetchProposals(): List<ImprovementProposal> {
        return improvementProposalsService.fetch()
    }
}
