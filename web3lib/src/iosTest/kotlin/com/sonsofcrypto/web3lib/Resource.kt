package com.sonsofcrypto.web3lib

import kotlinx.cinterop.*
import platform.Foundation.*
import platform.posix.*

actual class Resource {
    actual val name: String
    private val path: String?

    actual constructor(name: String) {
        this.name = name
        val split = name.split(".")
        this.path = NSBundle.mainBundle.pathForResource("res/" + split[0], split[1])
    }

    actual fun exists(): Boolean = NSFileManager.defaultManager.fileExistsAtPath(
        path ?: "-na"
    )

    actual fun readText(): String = NSString.stringWithContentsOfFile(
        path ?: "-na",
        NSUTF8StringEncoding,
        null
    ) ?: ""
}