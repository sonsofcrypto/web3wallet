package com.sonsofcrypto.web3lib.utils

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlin.coroutines.CoroutineContext

expect val bgDispatcher: CoroutineDispatcher

expect val uiDispatcher: CoroutineDispatcher

expect val logExceptionHandler: CoroutineExceptionHandler

expect fun currentThreadId(): String

expect suspend fun <T> withUICxt(block: suspend CoroutineScope.() -> T): T
expect suspend fun <T> withBgCxt(block: suspend CoroutineScope.() -> T): T
