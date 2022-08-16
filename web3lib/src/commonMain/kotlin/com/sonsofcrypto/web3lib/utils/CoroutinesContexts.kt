package com.sonsofcrypto.web3lib.utils

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineExceptionHandler

expect val bgDispatcher: CoroutineDispatcher

expect val uiDispatcher: CoroutineDispatcher

expect val logExceptionHandler: CoroutineExceptionHandler

expect fun currentThreadId(): String
