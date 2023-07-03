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

    fun id(): String = chainId.toString()

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
            sepolia().chainId,
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

    fun isValidAddress(input: String): Boolean = when (name) {
        "Ethereum" -> input.dropLast(40) == "0x" && input.length == 42
        else -> false
    }

    // TODO: Get address for Georly
    fun multicall3Address(): String = when (chainId) {
        ethereum().chainId,
        goerli().chainId,
        sepolia().chainId -> "0xcA11bde05977b3631167028862bE2a173976CA11"
        else -> throw Error("This network id $this does not have multicall")
    }

    companion object {
        fun ethereum() = Network("Ethereum", 1u, Type.L1, null, Currency.ethereum())
        fun goerli() = Network("Goerli", 5u, Type.L1_TEST, null, Currency.ethereum())
        fun sepolia() = Network("Sepolia", 11155111u, Type.L1_TEST, null, Currency.ethereum())

        fun fromChainId(chainId: UInt): Network = when(chainId) {
            5u -> goerli()
            11155111u -> sepolia()
            else -> ethereum()
        }
    }
}
