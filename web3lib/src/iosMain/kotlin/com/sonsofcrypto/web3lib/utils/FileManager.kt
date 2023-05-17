package com.sonsofcrypto.web3lib.utils

/**
 * `FileManager` handles interacting with all supported platforms.
 * Currently supporting iOS, Android, Unit tests run on host OS. TODO: JS support
 * - NOTE All paths are relative to bundle or workspace eg `folder/file.txt`
 * - NOTE When working with workspace files in unit test. Files are saved in `$rootProject/tmp`
 */
actual class FileManager {

    actual constructor(){}

    /** Reads data from file synchronously */
    @Throws(Throwable::class)
    actual fun readSync(path: String, location: Location): ByteArray {
        TODO("Implement")
    }

    /** Write data to file synchronously */
    @Throws(Throwable::class)
    actual fun writeSync(data: ByteArray, path: String) {
        TODO("Implement")
    }

    /** Reads data from file asynchronously */
    @Throws(Throwable::class)
    actual suspend fun read(path: String, location: Location): ByteArray {
        TODO("Implement")
    }

    /** Write data to file asynchronously */
    @Throws(Throwable::class)
    actual suspend fun write(data: ByteArray, path: String) {
        TODO("Implement")
    }


    /** Different locations file manger supports */
    actual enum class Location {
        BUNDLE, APPFILES;
    }
}