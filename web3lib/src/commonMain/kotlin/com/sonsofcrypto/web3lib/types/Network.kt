package com.sonsofcrypto.web3lib.types

import com.sonsofcrypto.web3lib.utils.keccak256
import kotlinx.serialization.Serializable

@Serializable
data class Network(
    val name: String,
    val chainId: UInt,
    val type: Type,
    val nameServiceAddress: AddressBytes?,
    val nativeCurrency: Currency,
) {

    fun id(): String = hashCode().toString()

    fun defaultDerivationPath(): String {
        return "m/44'/60'/0'/0/0"
    }

    fun address(pubKey: ExtKey): AddressBytes {
        val uncompressed = pubKey.uncompressedPub()
        val bytes = uncompressed.copyOfRange(1, uncompressed.size) // (strip prefix 0x04)
        return keccak256(bytes).copyOfRange(12, 32)
    }

    fun l1(network: Network): Network {
        return when (network.chainId) {
            ropsten().chainId,
            rinkeby().chainId,
            goerli().chainId -> {
               ethereum()
            }
            ethereum().chainId -> Network.ethereum()
            else -> throw Error("Unknown network id $network")
        }
    }
    enum class Type() {
        L1, L2, L1_TEST, L2_TEST;
    }

    companion object {
        fun ethereum() = Network("Ethereum", 1u, Type.L1, null, Currency.ethereum())
        fun ropsten() = Network("Ropsten", 3u, Type.L1_TEST, null, Currency.ethereum())
        fun rinkeby() = Network("Rinkeby", 4u, Type.L1_TEST, null, Currency.ethereum())
        fun goerli() = Network("Goerli", 5u, Type.L1_TEST, null, Currency.ethereum())

        fun supported(): List<Network> = listOf(
            Network.ethereum(),
            Network.ropsten(),
            Network.rinkeby(),
            Network.goerli(),
        )

        fun fromChainId(chainId: UInt): Network = when(chainId) {
            3u -> ropsten()
            4u -> rinkeby()
            5u -> goerli()
            else -> ethereum()
        }
    }
}
