package com.sonsofcrypto.web3lib.types

data class CurrencyAmount(
    val currency: Currency,
    val amount: BigInt, /** In base unit. eg Wei  */
)