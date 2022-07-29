package com.sonsofcrypto.web3lib_core

import com.sonsofcrypto.web3lib_utils.keccak256
import kotlinx.serialization.Serializable

@Serializable
class Network(
    val name: String,
    val chainId: UInt,
    val type: Type,
    val nameServiceAddress: AddressBytes?,
//    val nativeCurrency: Currency,
) {

    fun id(): String = hashCode().toString()

    fun address(pubKey: ByteArray): AddressBytes {
        return keccak256(pubKey).copyOfRange(12, 32)
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
        fun ethereum() = Network("Ethereum", 1u, Type.L1, null)
        fun ropsten() = Network("Ropsten", 3u, Type.L1_TEST, null)
        fun rinkeby() = Network("Rinkeby", 4u, Type.L1_TEST, null)
        fun goerli() = Network("Goerli", 5u, Type.L1_TEST, null)

        fun supported(): List<Network> = listOf(
            Network.ethereum(),
            Network.ropsten(),
            Network.rinkeby(),
            Network.goerli(),
        )
    }
}
