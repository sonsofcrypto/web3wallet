package com.sonsofcrypto.web3lib.utils

import android.os.Build
import com.sonsofcrypto.web3lib.appContextProvider.application
import com.sonsofcrypto.web3lib.types.ExtKey
import okio.FileSystem
import okio.Path.Companion.toPath
import okio.Source
import okio.buffer
import java.lang.Error


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

    /** Reads data from app bundle file asynchronously */
    @Throws(Throwable::class)
    actual fun bundleData(path: String, handler: (ByteArray)->Unit) {

    }

    /** Reads data from app bundle file synchronously */
    @Throws(Throwable::class)
    actual fun bundleData(path: String): ByteArray {
        val filePath = if (isUnitTestEnv) this.basePath() + "/$path" else path
        return read(filePath)
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

    private fun read(path: String): ByteArray {
        var result: ByteArray = ByteArray(0)
        if (isUnitTestEnv) {
            val source = FileSystem.SYSTEM.source(path.toPath(false))
            source.use { result = it.buffer().readByteArray() }
        } else {
            val stream = application?.assets?.open(path)
            stream?.let {
                result = it.readBytes()
                it.close()
            } ?: throw FileManager.Error.ReadAsset(path)
        }
        return result
    }

    private fun basePath(): String {
        if (isUnitTestEnv) {
            val pathComps = System.getProperty("user.dir")
                ?.split("/")
                ?.toMutableList()
                ?: return "android.resource://com.sonsofcrypto.web3wallet.android/raw/"
            while (pathComps.last() != "web3wallet") {
                pathComps.removeLast()
            }
            return pathComps.joinToString("/") + "/bundledAssets"
        } else {
            return "file:///android_asset"
        }
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