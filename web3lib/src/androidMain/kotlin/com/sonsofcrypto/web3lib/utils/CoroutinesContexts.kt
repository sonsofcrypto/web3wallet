package com.sonsofcrypto.web3lib.utils

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers

actual val uiDispatcher: CoroutineDispatcher
    get() = Dispatchers.Main

actual val bgDispatcher: CoroutineDispatcher
    get() = Dispatchers.Default

actual fun currentThreadId(): String {
    return "${Thread.currentThread().id} ${Thread.currentThread().name}"
}