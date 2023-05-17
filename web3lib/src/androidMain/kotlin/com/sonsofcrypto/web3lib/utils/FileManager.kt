package com.sonsofcrypto.web3lib.utils

import com.sonsofcrypto.web3lib.appContextProvider.application
import com.sonsofcrypto.web3lib.utils.FileManager.Location.AppFiles
import com.sonsofcrypto.web3lib.utils.FileManager.Location.Bundle
import okio.FileSystem
import okio.Path.Companion.toPath
import okio.buffer


/**
 * `FileManager` handles interacting with all supported platforms.
 * Currently supporting iOS, Android, Unit tests run on host OS. TODO: JS
 * - NOTE All paths are relative to bundle or workspace eg `folder/file.txt` if
 * path starts with `/` path is treated as absolute. (Relevant for unit tests)
 * - NOTE When working with workspace files in unit test. Files are saved in
 * `$rootProject/tmp`
 */
actual class FileManager {

    val isUnitTestEnv = EnvUtils().isUnitTestEnv()

    actual constructor(){}

    /** Reads data from app bundle file synchronously */
    @Throws(Throwable::class)
    actual fun readBundleSync(path: String): ByteArray {
        val filePath = if (isUnitTestEnv) this.basePath(Bundle) + "/$path" else path
        return internalRead(filePath, Bundle)
    }

    /** Reads data from app's workspace file synchronously */
    @Throws(Throwable::class)
    actual fun readSync(path: String): ByteArray {
        return internalRead(basePath() + "/$path")
    }

    private fun internalRead(path: String, location: Location = AppFiles): ByteArray {
        val result: ByteArray
        val p = if (location == Bundle && !isUnitTestEnv) path
                else basePath() + "/$path"
        if (path.first() == "/".first()) {
            TODO("Handle absolute app")
        }
        return when (location) {
            AppFiles -> {
                val source = FileSystem.SYSTEM.source(p.toPath(false))
                source.use { result = it.buffer().readByteArray() }
                result
            }
            Bundle -> {
                if (isUnitTestEnv) {
                    val source = FileSystem.SYSTEM.source(p.toPath(false))
                    source.use { result = it.buffer().readByteArray() }
                } else {
                    val stream = application?.assets?.open(p)
                    if (stream != null) {
                        result = stream.readBytes()
                        stream.close()
                    } else throw FileManager.Error.ReadAsset(p)
                }
                result
            }
        }
    }

    /** Write data to app's workspace file synchronously */
    @Throws(Throwable::class)
    actual fun writeSync(data: ByteArray, path: String) {
        val filePath = (this.basePath() + "/$path").toPath(false)
        val handle = FileSystem.SYSTEM.openReadWrite(filePath)
        handle.write(0, data, 0, data.size)
        handle.close()
    }

    /** Reads data from app bundle file asynchronously */
    @Throws(Throwable::class)
    actual suspend fun readBundle(path: String): ByteArray = withBgCxt {
        return@withBgCxt readBundleSync(path)
    }

    /** Reads data from app's workspace file asynchronously */
    @Throws(Throwable::class)
    actual suspend fun read(path: String): ByteArray = withBgCxt {
        return@withBgCxt readSync(path)
    }

    /** Write data to app's workspace file asynchronously */
    @Throws(Throwable::class)
    actual suspend fun write(data: ByteArray, path: String) = withBgCxt {
        writeSync(data, path)
        return@withBgCxt Unit
    }

    private fun basePath(location: Location = AppFiles): String {
        if (isUnitTestEnv) {
            return when (location) {
                Bundle -> unitTestBasePath() + "/bundledAssets"
                AppFiles -> unitTestBasePath() + "/tmp"
            }
        }
        return when (location) {
            Bundle -> "file:///android_asset"
            AppFiles -> application?.getFilesDir()?.absolutePath ?: "/"
        }
    }

    private fun unitTestBasePath(): String {
        val comps = (System.getProperty("user.dir") ?: "")
            .split("/")
            .toMutableList()
        while (comps.last() != "web3wallet") {
            comps.removeLast()
        }
        return comps.joinToString("/")
    }

    sealed class Location() {
        object Bundle: Location()
        object AppFiles: Location()
    }

    /** Exceptions */
    sealed class Error(
        message: String? = null,
        cause: Throwable? = null
    ) : Exception(message, cause) {

        constructor(cause: Throwable) : this(null, cause)

        /** Failed to read asset */
        class ReadAsset(val path: String) : Error("Failed to read asset $path")
    }
}