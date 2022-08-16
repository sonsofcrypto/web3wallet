package com.sonsofcrypto.web3lib.utils

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.Dispatchers

actual val uiDispatcher: CoroutineDispatcher
    get() = Dispatchers.Main

actual val bgDispatcher: CoroutineDispatcher
    get() = Dispatchers.Default

actual val logExceptionHandler: CoroutineExceptionHandler
    get() = CoroutineExceptionHandler { _, err -> println(err) }

actual fun currentThreadId(): String {
    return "${Thread.currentThread().id} ${Thread.currentThread().name}"
}