package com.sonsofcrypto.web3lib.utils

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import platform.Foundation.NSString
import platform.Foundation.NSUTF8StringEncoding
import platform.Foundation.stringWithCString
import platform.darwin.dispatch_get_current_queue
import platform.darwin.dispatch_queue_get_label

actual val uiDispatcher: CoroutineDispatcher
    get() = Dispatchers.Main

actual val bgDispatcher: CoroutineDispatcher
    get() = Dispatchers.Default

actual fun currentThreadId(): String {
    val cString = dispatch_queue_get_label(dispatch_get_current_queue())
    val string = NSString.stringWithCString(cString, encoding = NSUTF8StringEncoding)
    return "$string"
}