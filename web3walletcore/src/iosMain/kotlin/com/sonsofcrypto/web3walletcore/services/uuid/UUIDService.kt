package com.sonsofcrypto.web3walletcore.services.uuid

import platform.Foundation.NSUUID

actual class UUIDService {
    actual fun uuidString(): String = NSUUID().toString()
}
