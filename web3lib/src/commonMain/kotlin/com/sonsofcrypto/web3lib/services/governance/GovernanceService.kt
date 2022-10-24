package com.sonsofcrypto.web3lib.services.governance

import com.sonsofcrypto.web3lib.contract.Contract
import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.signer.Signer

/** Governance supports `GovernorAlpha`, `GovernorBravo` & Compound
 * compatibility */
interface GovernanceService {
    /** Fetches list of proposals */
    suspend fun proposals(): List<GovernanceProposal>
    /** Vote on proposals */
    suspend fun vote(proposal: GovernanceProposal, value: Int)
    // TODO: Add all the other relevant methods like delegating votes etc
}

class DefaultGovernanceService(
    val contract: Contract,
    val provider: Provider,
    val signer: Signer
): GovernanceService {

    override suspend fun proposals(): List<GovernanceProposal> {
        TODO("Implement")
    }

    override suspend fun vote(proposal: GovernanceProposal, value: Int) {
        TODO("Implement")
    }
}

