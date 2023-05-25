package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.provider.model.DataHexString
import com.sonsofcrypto.web3lib.provider.model.toByteArrayData
import com.sonsofcrypto.web3lib.utils.aesCTRXOR
import com.sonsofcrypto.web3lib.utils.secureRand
import io.ktor.utils.io.core.String
import io.ktor.utils.io.core.toByteArray
import kotlin.test.Test


class EncryptTest {

    @Test
    fun keygenTest() {
        val key = secureRand(16)
        val iv = secureRand(16)
        println("key ${DataHexString(key)}")
        println("iv ${DataHexString(iv)}")
    }

    @Test
    fun encryptTest() {
        val key = "".toByteArrayData()
        val iv = "".toByteArrayData()
        val test = ""
        val data = aesCTRXOR(key, test.toByteArray(), iv)
        println("cypherText ${DataHexString(data)}")
    }

    @Test
    fun dencryptTest() {
        val key = "".toByteArrayData()
        val iv = "".toByteArrayData()
        val cypherText = "".toByteArrayData()

        val data = aesCTRXOR(key, cypherText, iv)
        println("text ${String(data)}")
    }
}