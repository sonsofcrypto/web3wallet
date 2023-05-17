package com.sonsofcrypto.web3lib

import com.sonsofcrypto.web3lib.utils.FileManager
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class FileMangerTest {

    @Test
    fun testLoadBundlesFile() {
        val bytes: ByteArray = FileManager().bundleData("bitcoin_white_paper")
        assertEquals(
            bytes.decodeToString().length, 21896,
            "Failed to load bitcoin_white_paper.md"
        )
    }

}