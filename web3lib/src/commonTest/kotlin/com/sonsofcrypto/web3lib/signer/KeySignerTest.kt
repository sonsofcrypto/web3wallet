package com.sonsofcrypto.web3lib.signer

import com.sonsofcrypto.web3lib.assertBool
import com.sonsofcrypto.web3lib.types.toHexString
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.keccak256
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class KeySignerTest {

    data class SignMessageTestCase(
        val address: String,
        val name: String,
        val message: String?,
        val bytes: ByteArray,
        val hash: ByteArray,
        val prvKey: ByteArray,
        val signature: String,
    )

    @Test
    fun testSignMessage() = runBlocking {
        listOf(
            SignMessageTestCase(
                "0x14791697260E4c9A71f18484C9f997B308e59325",
                "string(\"hello world\")",
                "hello world",
                "hello world".encodeToByteArray(),
                "0xd9eba16ed0ecae432b71fe008c98cc872bb4cc214d3220a36f365326cf807d68".hexStringToByteArray(),
                "0x0123456789012345678901234567890123456789012345678901234567890123".hexStringToByteArray(),
                "0xddd0a7290af9526056b4e35a077b9a11b513aa0028ec6c9880948544508f3c63265e99e47ad31bb2cab9646c504576b3abc6939a1710afc08cbf3034d73214b81c",
            ),
            SignMessageTestCase(
                "0xD351c7c627ad5531Edb9587f4150CaF393c33E87",
                "bytes(0x47173285...4cb01fad)",
                null,
                "0x47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad".hexStringToByteArray(),
                "0x93100cc9477ba6522a2d7d5e83d0e075b167224ed8aa0c5860cfd47fa9f22797".hexStringToByteArray(),
                "0x51d1d6047622bca92272d36b297799ecc152dc2ef91b229debf84fc41e8c73ee".hexStringToByteArray(),
                "0x546f0c996fa4cfbf2b68fd413bfb477f05e44e66545d7782d87d52305831cd055fc9943e513297d0f6755ad1590a5476bf7d1761d4f9dc07dfe473824bbdec751b",
            ),
            SignMessageTestCase(
                "0xe7deA7e64B62d1Ca52f1716f29cd27d4FE28e3e1",
                "zero-prefixed signature",
                null,
                keccak256("0x7f23b5eed5bc7e89f267f339561b2697faab234a2".encodeToByteArray()),
                "0x06c9d148d268f9a13d8f94f4ce351b0beff3b9ba69f23abbf171168202b2dd67".hexStringToByteArray(),
                "0x09a11afa58d6014843fd2c5fd4e21e7fadf96ca2d8ce9934af6b8e204314f25c".hexStringToByteArray(),
                "0x7222038446034a0425b6e3f0cc3594f0d979c656206408f937c37a8180bb1bea047d061e4ded4aeac77fa86eb02d42ba7250964ac3eb9da1337090258ce798491c",
            ),
        ).forEach {
            println(it.name)
            val signer = KeySigner(it.prvKey)
            val address = signer.address().toHexString().lowercase()
            assertBool(
                it.address.lowercase() == address,
                "${it.name} address mismatch ${it.address} $address"
            )
            val bytes = it.message?.encodeToByteArray() ?: it.bytes
            val signature = signer.signMessage(bytes)
            assertBool(
                signature.toHexString(true) == it.signature,
                "Unexpected sig ${signature.toHexString(true)} ${it.signature}"
            )
        }
    }
}
