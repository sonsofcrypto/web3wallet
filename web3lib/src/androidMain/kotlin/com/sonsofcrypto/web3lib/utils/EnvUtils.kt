package com.sonsofcrypto.web3lib.utils


actual class EnvUtils {

    actual fun isUnitTest(): Boolean {
        listOf(
            "com.sonsofcrypto.web3lib.CommonTest",
            "com.sonsofcrypto.web3walletcore.CommonTest"
        ).forEach {
            try {
                Class.forName(it)
                return true
            } catch (e: Throwable) { Unit }
        }
        return false
    }

    actual fun isProd(): Boolean {
        TODO("Implement")
    }
}