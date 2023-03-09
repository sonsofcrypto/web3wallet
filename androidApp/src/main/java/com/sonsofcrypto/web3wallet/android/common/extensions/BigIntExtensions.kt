package com.sonsofcrypto.web3wallet.android.common.extensions

import androidx.compose.runtime.Composable
import androidx.compose.ui.text.AnnotatedString
import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.utils.BigDec
import com.sonsofcrypto.web3lib.utils.BigInt

fun BigInt.string(decimals: UInt): String = BigDec
    .from(this)
    .div(BigDec.from(BigInt.from(10).pow(decimals.toLong())))
    .toDecimalString()

fun BigInt.bigDec(decimals: UInt): BigDec = BigDec
    .from(this)
    .div(BigDec.from(BigInt.from(10).pow(decimals.toLong())))
