package com.sonsofcrypto.web3lib.utils

/**
 * `FileManager` handles interacting with all supported platforms.
 * Currently supporting iOS, Android, Unit tests run on host OS. TODO: JS support
 * - NOTE All paths are relative to bundle or workspace eg `folder/file.txt`
 * - NOTE When working with workspace files in unit test. Files are saved in `$rootProject/tmp`
 */
actual class FileManager {

    actual constructor(){}

    /** Reads data from app bundle file asynchronously */
    @Throws(Throwable::class)
    actual fun bundleData(path: String, handler: (ByteArray)->Unit) {

    }

    /** Reads data from app bundle file synchronously */
    @Throws(Throwable::class)
    actual fun bundleData(path: String): ByteArray {
        return ByteArray(0)
    }

    /** Reads data from app's workspace file asynchronously */
    @Throws(Throwable::class)
    actual fun workspaceData(path: String, handler: (ByteArray)->Unit) {

    }

    /** Reads data from app's workspace file synchronously */
    @Throws(Throwable::class)
    actual fun workspaceData(path: String): ByteArray {
        return ByteArray(0)
    }

    /** Write data to app's workspace file asynchronously */
    @Throws(Throwable::class)
    actual fun writeWorkspace(data: ByteArray, path: String, handler: ()->Unit) {

    }

    /** Write data to app's workspace file synchronously */
    @Throws(Throwable::class)
    actual fun writeWorkspace(data: ByteArray, path: String) {

    }

}