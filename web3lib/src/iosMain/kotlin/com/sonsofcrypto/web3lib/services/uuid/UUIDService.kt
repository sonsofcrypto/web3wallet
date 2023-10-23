package com.sonsofcrypto.web3lib.services.uuid

import platform.Foundation.NSUUID

actual class UUIDService {
    actual fun uuidString(): String = NSUUID().toString()
}
