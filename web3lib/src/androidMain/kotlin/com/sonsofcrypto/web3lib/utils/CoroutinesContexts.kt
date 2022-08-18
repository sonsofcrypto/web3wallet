package com.sonsofcrypto.web3lib.utils

import kotlinx.coroutines.*

actual val uiDispatcher: CoroutineDispatcher
    get() = Dispatchers.Main

actual val bgDispatcher: CoroutineDispatcher
    get() = Dispatchers.Default

actual val logExceptionHandler: CoroutineExceptionHandler
    get() = CoroutineExceptionHandler { _, err -> println(err) }

actual fun currentThreadId(): String {
    return "${Thread.currentThread().id} ${Thread.currentThread().name}"
}

actual suspend fun <T> withUICxt(block: suspend CoroutineScope.() -> T): T {
    return withContext(SupervisorJob() + uiDispatcher, block)
}

actual suspend fun <T> withBgCxt(block: suspend CoroutineScope.() -> T): T {
    return withContext(SupervisorJob() + bgDispatcher, block)
}
