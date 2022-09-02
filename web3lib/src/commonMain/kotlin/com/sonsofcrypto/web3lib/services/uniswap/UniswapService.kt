package com.sonsofcrypto.web3lib.services.uniswap

import com.sonsofcrypto.web3lib.provider.model.DataHexString
import com.sonsofcrypto.web3lib.services.wallet.WalletEvent
import com.sonsofcrypto.web3lib.services.wallet.WalletListener
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.types.*
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.abiEncode
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import com.sonsofcrypto.web3lib.utils.keccak256
import io.ktor.utils.io.core.*

/** Uniswap service events */
sealed class UniswapEvent() {

    /** Received new quote */
    data class QuoteChanged(
        val inputCurrency: Currency,
        val outputCurrency: Currency,
        val amount: BigInt,
    ): UniswapEvent()
}

interface UniswapListener { fun handle(event: UniswapEvent) }

/** Uniswap services */
interface UniswapService {
    var inputCurrency: Currency
    var outputCurrency: Currency

    var inputAmount: BigInt
    fun outputAmount(): BigInt
    fun outputState(): OutputState

    fun approvalState(): ApprovalState
    suspend fun requestApproval(currency: Currency, wallet: Wallet)

    suspend fun executeSwap()

    fun getPoolAddress(
        factoryAddress: AddressHexString,
        tokenAddressA: AddressHexString,
        tokenAddressB: AddressHexString,
        feeAmount: UniswapFeeAmount,
        poolInitHash: DataHexString,
    ): AddressHexString

    enum class UniswapFeeAmount(val value: UInt) {
        LOWEST(100u), LOW(500u), MEDIUM(3000u), HIGH(10000u)
    }

    /** Add listener for `WalletEvent`s */
    fun add(listener: UniswapListener)
    /** Remove listener for `WalletEvent`s, if null removes all listeners */
    fun remove(listener: UniswapListener?)

    /** Note that fee is in hundredths of basis points (e.g. the fee for a pool at
     *  the 0.3% tier is 3000; the fee for a pool at the 0.01% tier is 100).*/
    enum class PoolFee(val value: UInt) {
        LOWEST(100u), LOW(500u), MEDIUM(3000u), HIGH(10000u)
    }

    /** State of the pool for selected pair */
    sealed class PoolsState {
        object NoPoolsFound: PoolsState()
        object Loading: PoolsState()
        data class Valid(val poolState: Int): PoolsState()
    }

    /** Quote output state */
    sealed class OutputState {
        object Unavailable: OutputState()
        data class Loading(val previous: BigInt): OutputState()
        data class Valid(val quote: BigInt): OutputState()
    }

    /** State of ERC20 approval for router contract*/
    enum class ApprovalState {
        DOES_NO_APPLY, LOADING, NEEDS_APPROVAL, APPROVING, APPROVED
    }
}

class DefaultUniswapService: UniswapService {

    fun getPoolAddress(
        factoryAddress: AddressHexString,
        tokenAddressA: AddressHexString,
        tokenAddressB: AddressHexString,
        feeAmount: UniswapService.PoolFee,
        poolInitHash: DataHexString,
    ): AddressHexString {
        val addresses = this.sortedAddresses(tokenAddressA, tokenAddressB)
        val salt = keccak256(
            abiEncode(Address.HexString(addresses.first)) +
                    abiEncode(Address.HexString(addresses.second)) +
                    abiEncode(feeAmount.value)
        )
        val poolAddressBytes = keccak256(
            "0xff".hexStringToByteArray() +
                    factoryAddress.hexStringToByteArray() +
                    salt +
                    poolInitHash.hexStringToByteArray()
        ).copyOfRange(12, 32)

        return Address.Bytes(poolAddressBytes).toHexString()
    }

    fun getPoolData() {

    }

    fun sortedAddresses(
        addressA: AddressHexString,
        addressB: AddressHexString
    ): Pair<AddressHexString, AddressHexString> {
        return if (addressA.toLowerCase() < addressB.toLowerCase())
            Pair(addressA, addressB)
        else Pair(addressB, addressA)
    }
}