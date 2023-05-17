package com.sonsofcrypto.web3lib.utils


actual class EnvUtils {

    actual fun isUnitTestEnv(): Boolean {
        try {
            Class.forName("com.sonsofcrypto.web3lib.CommonTest");
            return true
        } catch (e: Throwable) {
            return false
        }
    }
}