package com.sonsofcrypto.web3wallet.android.common.extensions

import com.sonsofcrypto.web3lib.utils.BigDec
import com.sonsofcrypto.web3lib.utils.BigInt

fun BigInt.string(decimals: UInt): String = BigDec
    .from(this)
    .div(BigDec.from(BigInt.from(10).pow(decimals.toLong())))
    .toDecimalString()