package com.sonsofcrypto.web3walletcore.modules.improvementProposals

import com.sonsofcrypto.web3walletcore.services.ImprovmentProposals.ImprovementProposal
import com.sonsofcrypto.web3walletcore.services.ImprovmentProposals.ImprovementProposalsService

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
