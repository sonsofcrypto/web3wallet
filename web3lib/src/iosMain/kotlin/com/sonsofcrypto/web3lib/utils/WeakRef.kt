package com.sonsofcrypto.web3lib.utils

import kotlin.native.ref.WeakReference

actual class WeakRef<T : Any> {
    private val ref: WeakReference<T>

    actual constructor(referred: T) {
        ref = WeakReference(referred)
    }

    actual fun clear() = ref.clear()
    actual fun get(): T? = ref.get()
    actual val value: T?
        get() = ref.value
}
