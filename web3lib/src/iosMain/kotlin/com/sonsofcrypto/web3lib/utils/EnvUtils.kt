package com.sonsofcrypto.web3lib.utils

import platform.Foundation.NSBundle

actual class EnvUtils {

    actual fun isUnitTestEnv(): Boolean {
        return NSBundle.mainBundle.bundlePath.split("/").last().contains("Test")
    }
}