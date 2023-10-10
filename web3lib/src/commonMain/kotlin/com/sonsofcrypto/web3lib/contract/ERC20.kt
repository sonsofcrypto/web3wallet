package com.sonsofcrypto.web3lib.contract

import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.signer.SignerIntf
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.utils.BigInt

/** Standard ERC20 https://eips.ethereum.org/EIPS/eip-20 */
class ERC20: Contract {
    constructor(
        address: Address.HexString? = null,
        provider: Provider? = null,
        signerIntf: SignerIntf? = null
    ) : super(listOf(ERC20.abi()), address, provider, signerIntf)
    /** Returns `BigInt` */
    fun decimals(): Method = method("decimals()")
    /** Returns `BigInt` */
    fun balanceOf(address: Address.HexString): Method =
        method("balanceOf(address)")

    companion object {
        fun abi(): String {
            TODO("Load ERC20 json file")
        }
    }
}

suspend fun example() {
    val decimals = ERC20().decimals().call() as BigInt
}