package com.sonsofcrypto.web3lib.utils

/**
 * `FileManager` handles interacting with all supported platforms.
 * Currently supporting iOS, Android, Unit tests run on host OS. TODO: JS support
 * - NOTE All paths are relative to bundle or workspace eg `folder/file.txt`
 * - NOTE When working with workspace files in unit test. Files are saved in `$rootProject/tmp`
 */
expect class FileManager {
    constructor()
    /** Reads data from file synchronously */
    @Throws(Throwable::class)
    fun readSync(path: String, location: Location = Location.APPFILES): ByteArray
    /** Write data to file synchronously */
    @Throws(Throwable::class)
    fun writeSync(data: ByteArray, path: String)
    /** Reads data from file asynchronously */
    @Throws(Throwable::class)
    suspend fun read(path: String, location: Location = Location.APPFILES): ByteArray
    /** Write data to file asynchronously */
    @Throws(Throwable::class)
    suspend fun write(data: ByteArray, path: String)

    /** Different locations file manger supports */
    enum class Location {
        BUNDLE, APPFILES;
    }
}
