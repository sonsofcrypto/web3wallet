package com.sonsofcrypto.web3lib.utils

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.launch
import kotlin.time.Duration

fun timerFlow(period: Duration, initialDelay: Duration = Duration.ZERO) = flow {
    delay(initialDelay)
    while (true) {
        emit(Unit)
        delay(period)
    }
}

fun execDelayed(
    delay: Duration,
    dispatcher: CoroutineDispatcher = uiDispatcher,
    block: ()->Unit
) {
    CoroutineScope(dispatcher).launch {
        delay(delay)
        block()
    }
}