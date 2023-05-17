package com.sonsofcrypto.web3lib.utils

import com.sonsofcrypto.web3lib.appContextProvider.application
import com.sonsofcrypto.web3lib.utils.FileManager.Location.APPFILES
import com.sonsofcrypto.web3lib.utils.FileManager.Location.BUNDLE
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

    /** Reads data from file synchronously */
    actual fun readSync(path: String, location: Location): ByteArray {
        val result: ByteArray
        val p = if (location == BUNDLE && !isUnitTestEnv) path
                else basePath(location) + "/$path"
        if (path.first() == "/".first()) {
            TODO("Handle absolute app")
        }
        return when (location) {
            APPFILES -> {
                val source = FileSystem.SYSTEM.source(p.toPath(false))
                source.use { result = it.buffer().readByteArray() }
                result
            }
            BUNDLE -> {
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

    /** Write data to file synchronously */
    @Throws(Throwable::class)
    actual fun writeSync(data: ByteArray, path: String) {
        val filePath = (this.basePath() + "/$path").toPath(false)
        val handle = FileSystem.SYSTEM.openReadWrite(filePath)
        handle.write(0, data, 0, data.size)
        handle.close()
    }

    /** Reads data from file asynchronously */
    @Throws(Throwable::class)
    actual suspend fun read(path: String, location: Location): ByteArray = withBgCxt {
        return@withBgCxt readSync(path)
    }

    /** Write data to file asynchronously */
    @Throws(Throwable::class)
    actual suspend fun write(data: ByteArray, path: String) = withBgCxt {
        writeSync(data, path)
        return@withBgCxt Unit
    }

    /** Different locations file manger supports */
    actual enum class Location {
        BUNDLE, APPFILES;
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

    private fun basePath(location: Location = APPFILES): String {
        if (isUnitTestEnv) {
            return when (location) {
                BUNDLE -> unitTestBasePath() + "/bundledAssets"
                APPFILES -> unitTestBasePath() + "/tmp"
            }
        }
        return when (location) {
            BUNDLE -> "file:///android_asset"
            APPFILES -> application?.getFilesDir()?.absolutePath ?: "/"
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
}