package com.sonsofcrypto.web3lib.services.uuid

import java.util.UUID

actual class UUIDService {
    actual fun uuidString(): String = UUID.randomUUID().toString()
}