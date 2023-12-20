@file:OptIn(ExperimentalForeignApi::class)

package com.sonsofcrypto.web3lib.services.uuid

import kotlinx.cinterop.ExperimentalForeignApi
import platform.Foundation.NSUUID

actual class UUIDService {
    actual fun uuidString(): String = NSUUID().toString()
}
