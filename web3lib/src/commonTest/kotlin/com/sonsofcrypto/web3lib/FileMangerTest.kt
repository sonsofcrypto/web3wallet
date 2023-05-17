package com.sonsofcrypto.web3lib

import com.sonsofcrypto.web3lib.utils.FileManager
import io.ktor.utils.io.core.toByteArray
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class FileMangerTest {

    @Test
    fun testReadBundlesFile() {
        val bytes: ByteArray = FileManager().readBundleSync("bitcoin_white_paper.md")
        assertTrue(
            bytes.decodeToString().length == 21896,
            "Failed to load bitcoin_white_paper.md"
        )
    }

    @Test
    fun testReadWorkspaceFile() {
        val fm = FileManager()
        fm.writeWorkspaceSync("Testing".toByteArray(), "test.txt")
        assertTrue(
            fm.readWorkspaceSync("test.txt").decodeToString() == "Testing",
            "Failed to load  test.txt"
        )
    }
}