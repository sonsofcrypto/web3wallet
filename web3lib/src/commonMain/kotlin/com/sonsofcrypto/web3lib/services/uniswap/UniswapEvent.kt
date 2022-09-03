package com.sonsofcrypto.web3lib.services.uniswap

/** Uniswap service events */
sealed class UniswapEvent() {

    /** Pools state changed */
    data class PoolsState(
        val state: com.sonsofcrypto.web3lib.services.uniswap.PoolsState,
    ): UniswapEvent()

    /** Output state changed */
    data class OutputState(
        val state: com.sonsofcrypto.web3lib.services.uniswap.OutputState,
    ): UniswapEvent()

    /** Approval state */
    data class ApprovalState(
        val state: com.sonsofcrypto.web3lib.services.uniswap.ApprovalState,
    ): UniswapEvent()
}

