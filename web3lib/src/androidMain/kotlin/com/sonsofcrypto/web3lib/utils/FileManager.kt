package com.sonsofcrypto.web3lib.utils

import com.sonsofcrypto.web3lib.appContextProvider.application
import okio.BufferedSource
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
        val filePath = if (isUnitTestEnv) this.basePathBundle() + "/$path" else path
        return read(filePath)
    }

    /** Reads data from app's workspace file synchronously */
    @Throws(Throwable::class)
    actual fun readWorkspaceSync(path: String): ByteArray {
        val filePath = this.basePathWorkspace() + "/$path"
        return read(filePath, Location.Workspace)
    }

    /** Write data to app's workspace file synchronously */
    @Throws(Throwable::class)
    actual fun writeWorkspaceSync(data: ByteArray, path: String) {
        val filePath = this.basePathWorkspace() + "/$path"
        write(data, filePath)
    }

    private fun write(data: ByteArray, path: String) {
        val filePath = path.toPath(false)
        println("writing $path")
        println("writing ${filePath.segments}")
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
    actual suspend fun readWorkspace(path: String): ByteArray = withBgCxt {
        return@withBgCxt readWorkspaceSync(path)
    }

    /** Write data to app's workspace file asynchronously */
    @Throws(Throwable::class)
    actual suspend fun writeWorkspace(data: ByteArray, path: String) = withBgCxt {
        writeWorkspaceSync(data, path)
        return@withBgCxt Unit
    }

    private fun read(path: String, location: Location = Location.Bundle): ByteArray {
        var result: ByteArray = ByteArray(0)
        if (isUnitTestEnv) {
            val source = FileSystem.SYSTEM.source(path.toPath(false))
            source.use { result = it.buffer().readByteArray() }
        } else {
            if (location == Location.Workspace) {
                println("READING $path")
                val source = FileSystem.SYSTEM.source(path.toPath(false))
                source.use { result = it.buffer().readByteArray() }
                return result
            }
            val stream = application?.assets?.open(path)
            stream?.let {
                result = it.readBytes()
                it.close()
            } ?: throw FileManager.Error.ReadAsset(path)
        }
        return result
    }

    private fun basePathBundle(): String {
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

    private fun basePathWorkspace(): String {
        if (isUnitTestEnv) {
            val pathComps = System.getProperty("user.dir")
                ?.split("/")
                ?.toMutableList()
                ?: return "android.resource://com.sonsofcrypto.web3wallet.android/raw/"
            while (pathComps.last() != "web3wallet") {
                pathComps.removeLast()
            }
            return pathComps.joinToString("/") + "/tmp"
        } else {
            return application?.getFilesDir()?.absolutePath ?: "/"
        }
    }

    sealed class Location() {
        object Bundle: Location()
        object Workspace: Location()
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