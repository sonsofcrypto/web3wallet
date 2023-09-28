package com.sonsofcrypto.web3lib.utils

import platform.Foundation.NSBundle

actual class EnvUtils {

    actual fun isUnitTest(): Boolean {
        return NSBundle.mainBundle.bundlePath.split("/").last().contains("Test")
    }

    actual fun isProd(): Boolean {
        return NSBundle.mainBundle.bundleIdentifier == "com.sonsofcrypto.web3wallet"
    }
}