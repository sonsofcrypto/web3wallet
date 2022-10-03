package com.sonsofcrypto.web3walletcore.services.ImprovmentProposals

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore

interface ImprovementProposalsService {
    /** Fetched proposals for github */
    @Throws(Throwable::class)
    suspend fun fetch(): List<ImprovementProposal>
}

final class DefaultImprovementProposalsService(
    val store: KeyValueStore
): ImprovementProposalsService {

    @Throws(Throwable::class)
    override suspend fun fetch(): List<ImprovementProposal> {

    }
}
