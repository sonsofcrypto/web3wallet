package com.sonsofcrypto.web3wallet.android.common.ui

import com.sonsofcrypto.web3lib.types.NetworkFee

data class DialogNetworkFee(
    val networkFees: List<NetworkFee>,
    val networkFee: NetworkFee?,
)