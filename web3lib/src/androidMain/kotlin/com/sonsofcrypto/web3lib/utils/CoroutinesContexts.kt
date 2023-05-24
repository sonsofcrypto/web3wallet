package com.sonsofcrypto.web3lib.utils

import kotlinx.coroutines.*
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit


private val pool: ExecutorService = Executors.newFixedThreadPool(1)
private val uiMockDispatcher = pool.asCoroutineDispatcher()

actual val uiDispatcher: CoroutineDispatcher
    get() = if (EnvUtils().isUnitTestEnv()) uiMockDispatcher else Dispatchers.Main

actual val bgDispatcher: CoroutineDispatcher
    get() = Dispatchers.Default

actual val logExceptionHandler: CoroutineExceptionHandler
    get() = CoroutineExceptionHandler { _, err ->
        println("[CAUGHT EXCEPTION] $err")
    }

actual fun currentThreadId(): String {
    return "${Thread.currentThread().id} ${Thread.currentThread().name}"
}

actual suspend fun <T> withUICxt(block: suspend CoroutineScope.() -> T): T {
    return withContext(SupervisorJob() + uiDispatcher, block)
}

actual suspend fun <T> withBgCxt(block: suspend CoroutineScope.() -> T): T {
    return withContext(SupervisorJob() + bgDispatcher, block)
}


