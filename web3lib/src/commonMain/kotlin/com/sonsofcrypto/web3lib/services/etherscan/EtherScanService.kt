package com.sonsofcrypto.web3lib.services.etherscan

import com.sonsofcrypto.web3lib.BuildKonfig

interface EtherScanService {
    fun apiKey(): String
}

class DefaultEtherScanService: EtherScanService {
    override fun apiKey(): String = BuildKonfig.etherscanKey
}