package com.sonsofcrypto.web3lib.utils

import kotlinx.coroutines.CoroutineDispatcher

expect val bgDispatcher: CoroutineDispatcher

expect val uiDispatcher: CoroutineDispatcher

expect fun currentThreadId(): String