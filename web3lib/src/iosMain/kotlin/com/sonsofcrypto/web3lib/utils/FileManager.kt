package com.sonsofcrypto.web3lib.utils

/**
 * `FileManager` handles interacting with all supported platforms.
 * Currently supporting iOS, Android, Unit tests run on host OS. TODO: JS support
 * - NOTE All paths are relative to bundle or workspace eg `folder/file.txt`
 * - NOTE When working with workspace files in unit test. Files are saved in `$rootProject/tmp`
 */
actual class FileManager {

    actual constructor(){}

    /** Reads data from app bundle file synchronously */
    @Throws(Throwable::class)
    actual fun readBundleSync(path: String): ByteArray {
        TODO("Implement")
    }

    /** Reads data from app's workspace file synchronously */
    @Throws(Throwable::class)
    actual fun readWorkspaceSync(path: String): ByteArray {
        TODO("Implement")
    }

    /** Write data to app's workspace file synchronously */
    @Throws(Throwable::class)
    actual fun writeWorkspaceSync(data: ByteArray, path: String) {
        TODO("Implement")
    }

    /** Reads data from app bundle file asynchronously */
    @Throws(Throwable::class)
    actual suspend fun readBundle(path: String): ByteArray {
        TODO("Implement")
    }

    /** Reads data from app's workspace file asynchronously */
    @Throws(Throwable::class)
    actual suspend fun readWorkspace(path: String): ByteArray {
        TODO("Implement")
    }

    /** Write data to app's workspace file asynchronously */
    @Throws(Throwable::class)
    actual suspend fun writeWorkspace(data: ByteArray, path: String) {
        TODO("Implement")
    }
}