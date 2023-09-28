package com.sonsofcrypto.web3lib.utils

expect class EnvUtils {
    constructor()
    fun isUnitTest(): Boolean
    fun isProd(): Boolean
}
