package com.sonsofcrypto.web3lib_core

/** CoinType https://github.com/satoshilabs/slips/blob/master/slip-0044.md */
data class CoinType(val value: UInt)


sealed class CoinInfo(
    val symbol: String,
    val ilk: String? = null,    // General family
    val prefix: String? = null, // Bech32 prefix
    val p2pkh: UInt? = null,    // Pay-to-Public-Key-Hash Version
    val p2sh: UInt? = null,     // Pay-to-Script-Hash Version
)
