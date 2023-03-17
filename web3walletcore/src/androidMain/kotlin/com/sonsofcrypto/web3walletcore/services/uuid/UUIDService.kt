package com.sonsofcrypto.web3walletcore.services.uuid

import java.util.UUID

actual class UUIDService {
    actual fun uuidString(): String = UUID.randomUUID().toString()
}