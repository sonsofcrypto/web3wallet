package com.sonsofcrypto.web3lib_extensions

import kotlinx.cinterop.addressOf
import kotlinx.cinterop.pin
import kotlinx.cinterop.usePinned
import platform.Foundation.NSData
import platform.Foundation.create
import platform.posix.memcpy


fun ByteArray.data(): NSData = toData()

fun ByteArray.toData(offset: Int = 0, length: Int = size - offset): NSData {
    require(offset + length <= size) { "offset + length > size" }
    if (isEmpty()) return NSData()
    val pinned = pin()
    return NSData.create(pinned.addressOf(offset), length.toULong()) { _, _ -> pinned.unpin() }
}

fun ByteArray.from(data: NSData): ByteArray {
    val size = data.length.toInt()
    val bytes = ByteArray(size)

    if (size > 0) {
        bytes.usePinned { pinned ->
            memcpy(pinned.addressOf(0), data.bytes, data.length)
        }
    }

    return bytes
}

fun NSData.byteArray(): ByteArray {
    val size = length.toInt()
    val bytes = ByteArray(size)

    if (size > 0) {
        bytes.usePinned { pinned ->
            memcpy(pinned.addressOf(0), this.bytes, this.length)
        }
    }

    return bytes
}
