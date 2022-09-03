package com.sonsofcrypto.web3lib.services.uniswap

import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.ProviderVoid
import com.sonsofcrypto.web3lib.provider.call
import com.sonsofcrypto.web3lib.provider.model.DataHexString
import com.sonsofcrypto.web3lib.provider.model.TransactionRequest
import com.sonsofcrypto.web3lib.services.uniswap.contracts.Quoter
import com.sonsofcrypto.web3lib.services.uniswap.contracts.UniswapV3PoolState
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.signer.contracts.ERC20
import com.sonsofcrypto.web3lib.types.*
import com.sonsofcrypto.web3lib.utils.*
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import kotlinx.coroutines.*
import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.flow.*
import kotlin.time.Duration.Companion.seconds

/** Note that fee is in hundredths of basis points (e.g. the fee for a pool at
 *  the 0.3% tier is 3000; the fee for a pool at the 0.01% tier is 100).*/
enum class PoolFee(val value: UInt) {
    LOWEST(100u), LOW(500u), MEDIUM(3000u), HIGH(10000u)
}

/** State of the pool for selected pair */
sealed class PoolsState {
    object NoPoolsFound: PoolsState()
    object Loading: PoolsState()
    data class Valid(val poolFees: List<PoolFee>): PoolsState()

    fun validFees(): List<PoolFee> = when(this) {
        is PoolsState.Valid -> this.poolFees
        else -> listOf()
    }
}

/** Quote output state */
sealed class OutputState {
    object Unavailable: OutputState()
    data class Loading(val quote: BigInt, val request: QuoteRequest): OutputState()
    data class Valid(val quote: BigInt, val request: QuoteRequest): OutputState()
}

/** State of ERC20 approval for router contract*/
enum class ApprovalState {
    DOES_NO_APPLY, LOADING, NEEDS_APPROVAL, APPROVING, APPROVED
}

interface UniswapListener { fun handle(event: UniswapEvent) }

/** Uniswap services */
interface UniswapService {
    var inputCurrency: Currency
    var outputCurrency: Currency
    var inputAmount: BigInt
    val outputAmount: BigInt
    val poolsState: PoolsState
    val approvalState: ApprovalState
    val outputState: OutputState
    var provider: Provider
    val wallet: Wallet?

    suspend fun requestApproval(currency: Currency, wallet: Wallet)
    suspend fun executeSwap()

    /** Add listener for `Uniswap`s */
    fun add(listener: UniswapListener)
    /** Remove listener for `Uniswap`s, if null removes all listeners */
    fun remove(listener: UniswapListener?)
}

private val QUOTE_DEBOUNCE_MS = 750L
private val UINT256_MAX = BigInt.from("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", 16)

class DefaultUniswapService(
    override var provider: Provider = ProviderVoid(Network.ethereum()),
    override var wallet: Wallet? = null
): UniswapService {
    override var inputCurrency: Currency = Currency.ethereum()
        set(value) {
            field = value
            currencyChanged(value, outputCurrency)
        }
    override var outputCurrency: Currency = Currency.cult()
        set(value) {
            field = value
            currencyChanged(inputCurrency, value)
        }
    override var inputAmount: BigInt = BigInt.zero()
        set(value) {
            field = value
            inputChanged(inputCurrency, outputCurrency, value)
        }
    override var outputAmount: BigInt = BigInt.zero()
        get() {
            val state = outputState
            return when (state) {
                is OutputState.Loading -> return state.quote
                is OutputState.Valid -> return state.quote
                else -> return BigInt.zero()
            }
        }
        private set
    override var poolsState: PoolsState = PoolsState.Loading
        private set(value) {
            field = value
            emit(UniswapEvent.PoolsState(value))
            inputChanged(inputCurrency, outputCurrency, inputAmount)
        }
    override var approvalState: ApprovalState = ApprovalState.LOADING
        private set(value) {
            field = value
            emit(UniswapEvent.ApprovalState(value))
            inputChanged(inputCurrency, outputCurrency, inputAmount)
        }
    override var outputState: OutputState = OutputState.Unavailable
        private set(value) {
            field = value
            emit(UniswapEvent.OutputState(value))
        }

    private val network = Network.ethereum()
    private var listeners: MutableSet<UniswapListener> = mutableSetOf()
    private val scope = CoroutineScope(SupervisorJob() + bgDispatcher)
    private var poolsStateJob: Job? = null
    private val quoteFlow = MutableSharedFlow<QuoteRequest>(
        extraBufferCapacity = 1,
        onBufferOverflow = BufferOverflow.DROP_OLDEST
    )

    init {
        quoteFlow
            .debounce(QUOTE_DEBOUNCE_MS)
            .flatMapLatest { request -> fetchBestQuote(request) }
            .onEach {
                val (quote, fee, request) = it
                handleQuote(quote, fee, request)
            }
            .launchIn(scope)
    }

    override suspend fun requestApproval(currency: Currency, wallet: Wallet) {
        approvalState = ApprovalState.APPROVING
        val spender = routerAddress(provider.network)
        scope.launch {
            val state = approve(currency, spender, wallet)
            withUICxt { approvalState = state }
        }
    }

    override suspend fun executeSwap() {
        TODO("Implement")
    }

    private fun currencyChanged(input: Currency, output: Currency) {
        poolsStateJob?.cancel(null)
        poolsState = PoolsState.Loading
        approvalState = ApprovalState.LOADING
        val owner = wallet?.address()?.toHexStringAddress()?.hexString
        val spender = routerAddress(provider.network)
        val amount = inputAmount
        poolsStateJob = scope.launch {
            val fees = fetchValidPoolFeeProtocols(input, output, provider)
            withUICxt {
                poolsState = if (fees.isEmpty()) PoolsState.NoPoolsFound
                else PoolsState.Valid(fees)
            }
            val state = fetchApprovalState(input, owner, spender, amount, provider)
            withUICxt { approvalState = state }
        }
    }

    private fun inputChanged(input: Currency, output: Currency, value: BigInt) {
        val curr = outputState
        val fees = poolsState.validFees()
        if (poolsState is PoolsState.NoPoolsFound)
            OutputState.Unavailable
        if (fees.isEmpty())
            return
        outputState = when (curr) {
            is OutputState.Loading -> OutputState.Loading(curr.quote, curr.request)
            is OutputState.Valid -> OutputState.Loading(curr.quote, curr.request)
            else -> OutputState.Loading(
                BigInt.zero(),
                QuoteRequest(input, output, BigInt.zero(), fees, provider)
            )
        }
        scope.launch {
            quoteFlow.emit(QuoteRequest(input, output, value, fees, provider))
        }
    }

    /** Quotes */

    suspend fun fetchBestQuote(
        request: QuoteRequest
    ): Flow<Triple<BigInt, PoolFee, QuoteRequest>> = flow {
        if (request.amountIn.isZero()) {
            emit(Triple(request.amountIn, PoolFee.LOW, request))
            return@flow
        }
        val results: MutableList<Triple<BigInt, PoolFee, QuoteRequest>> = mutableListOf()
        PoolFee.values().forEach {
            val quote = fetchQuote(request, it)
            results.add(Triple(quote, it, request))
        }
        results.sortWith(ComparatorFetchQuoteTriple)
        emit(results.last())
    }

    suspend fun fetchQuote(request: QuoteRequest, fee: PoolFee): BigInt {
        val network = provider.network
        val quoter = Quoter(Address.HexString(quoterAddress(network)))
        try {
            val quoteResult = provider.call(
                quoter.address.hexString,
                quoter.quoteExactInputSingle(
                    Address.HexString(wrappedAddress(request.input)),
                    Address.HexString(wrappedAddress(request.output)),
                    fee.value,
                    request.amountIn,
                    0u
                )
            )
            return abiDecodeBigInt(quoteResult)
        } catch (err: Throwable) {
            println("Error fetching quote  $err, ${request.input}, ${request.output}, ${request.amountIn}, $fee")
            return BigInt.zero()
        }
    }

    suspend fun handleQuote(quote: BigInt, fee: PoolFee, request: QuoteRequest) = withUICxt {
        if (quote.isZero()) outputState = OutputState.Unavailable
        else outputState = OutputState.Valid(quote, request)
    }

    /** Pools */

    suspend fun fetchValidPoolFeeProtocols(
        input: Currency,
        output: Currency,
        provider: Provider
    ): List<PoolFee> = withBgCxt {
        val network = provider.network
        val valid: MutableList<PoolFee> = mutableListOf()
        PoolFee.values().forEach { fee ->
            val address = poolAddress(input, output, fee, network)
            val poolState = UniswapV3PoolState(Address.HexString(address))
            try {
                val resultSlot0 = provider.call(address, poolState.slot0())
                val slot0 = poolState.decodeSlot(resultSlot0)
                if (slot0.unlocked) {
                    valid.add(fee)
                }
            } catch (err: Throwable) {
                println("Error fetching pool state $fee, $err")
            }
        }
        return@withBgCxt valid
    }

    fun poolAddress(
        input: Currency,
        output: Currency,
        fee: PoolFee,
        network: Network
    ): AddressHexString = poolAddress(
        factoryAddress(network),
        wrappedAddress(input),
        wrappedAddress(output),
        fee,
        poolInitHash(network)
    )

    fun poolAddress(
        factoryAddress: AddressHexString,
        tokenAddressA: AddressHexString,
        tokenAddressB: AddressHexString,
        feeAmount: PoolFee,
        poolInitHash: DataHexString
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

    suspend fun fetchPoolsStates(
        pools: List<AddressHexString>
    ): Map<AddressHexString, UniswapV3PoolState.Slot0> {
        var results = mutableMapOf<AddressHexString, UniswapV3PoolState.Slot0>()
        pools.forEach {
            val poolState = UniswapV3PoolState(Address.HexString(it))
            try {
                val resultSlot0 = provider.call(it, poolState.slot0())
                results[it] = poolState.decodeSlot(resultSlot0)
            } catch (err: Throwable) {
                println("Error fetching pool state $it, $err")
            }
        }
        return results
    }

    /** Approval */

    suspend fun fetchApprovalState(
        currency: Currency,
        owner: AddressHexString?,
        spender: AddressHexString,
        amount: BigInt,
        provider: Provider
    ): ApprovalState {
        val tokenAddress = wrappedAddress(currency)
        val erc20 = ERC20(Address.HexString(tokenAddress))
        if (owner == null)
            return ApprovalState.DOES_NO_APPLY
        try {
            val data = erc20.allowance(
                Address.HexString(owner),
                Address.HexString(spender)
            )
            val result = provider.call(tokenAddress, data)
            val allowance = erc20.decodeAllowance(result)
            return if (allowance.isZero()) {
                ApprovalState.NEEDS_APPROVAL
            } else if (amount.isZero() && !allowance.isZero()) {
                ApprovalState.APPROVED
            } else if (amount.compare(allowance) >= 0) {
                ApprovalState.APPROVED
            } else {
                ApprovalState.NEEDS_APPROVAL
            }
        } catch (err: Throwable) {
            println("Error approving $err")
            return ApprovalState.NEEDS_APPROVAL
        }
    }

    suspend fun approve(
        currency: Currency,
        spender: AddressHexString,
        wallet: Wallet
    ): ApprovalState {
        val tokenAddress = wrappedAddress(currency)
        val erc20 = ERC20(Address.HexString(tokenAddress))
        try {
            val data = erc20.approve(Address.HexString(spender), UINT256_MAX)
            val request = TransactionRequest(to = erc20.address, data = data)
            val response = wallet!!.sendTransaction(request)
            var throwCount = 0
            while (throwCount < 10) {
                delay(5.seconds)
                try {
                    val receipt = wallet.provider()!!.getTransactionReceipt(response.hash)
                    println("${receipt.status} $receipt")
                    if (receipt.status == 1 && receipt.confirmations?.isZero() == false) {
                        return ApprovalState.APPROVED
                    }
                    if (receipt.status == 0) {
                        return ApprovalState.NEEDS_APPROVAL
                    }
                    throwCount = 0
                } catch (err: Throwable) {
                    throwCount += 1
                    println("Receipt error $throwCount $err")
                }
            }
            return ApprovalState.NEEDS_APPROVAL
        } catch (err: Throwable) {
            println("Error approving $err")
            return ApprovalState.NEEDS_APPROVAL
        }
    }

    /** Listeners */

    override fun add(listener: UniswapListener) {
        listeners.add(listener)
    }

    override fun remove(listener: UniswapListener?) {
        if (listener != null) listeners.remove(listener)
        else listeners = mutableSetOf()
    }

    private fun emit(event: UniswapEvent) {
        listeners.forEach { it.handle(event)}
        println("=== $event")
    }

    private fun wrappedAddress(currency: Currency): AddressHexString {
        return if (currency.type == Currency.Type.NATIVE)
            // TODO: Add support for test nets
            when(network) {
                Network.ethereum() -> "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
                else -> "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
            }
        else currency.address!!
    }

    // TODO: Add support for test nets
    private fun factoryAddress(network: Network): AddressHexString = when(network) {
        Network.ethereum() -> "0x1F98431c8aD98523631AE4a59f267346ea31F984"
        else -> "0x1F98431c8aD98523631AE4a59f267346ea31F984"
    }

    // TODO: Add support for test nets
    fun routerAddress(network: Network): AddressHexString = when(network) {
        Network.ethereum() -> "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45"
        else -> "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45"
    }

    // TODO: Add support for test nets
    private fun quoterAddress(network: Network): AddressHexString = when(network) {
        Network.ethereum() -> "0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6"
        else -> "0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6"
    }

    // TODO: Add support for test nets
    private fun poolInitHash(network: Network): AddressHexString = when(network) {
        Network.ethereum() -> "0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54"
        else -> "0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54"
    }

    private fun sortedAddresses(
        addressA: AddressHexString,
        addressB: AddressHexString
    ): Pair<AddressHexString, AddressHexString> {
        return if (addressA.toLowerCase() < addressB.toLowerCase())
            Pair(addressA, addressB)
        else Pair(addressB, addressA)
    }
}

data class QuoteRequest (
    val input: Currency,
    val output: Currency,
    val amountIn: BigInt,
    val fees: List<PoolFee>,
    val provider: Provider
)

class ComparatorFetchQuoteTriple {
    companion object : Comparator<Triple<BigInt, PoolFee, QuoteRequest>> {
        override fun compare(
            a: Triple<BigInt, PoolFee, QuoteRequest>,
            b: Triple<BigInt, PoolFee, QuoteRequest>
        ): Int = a.first.compare(b.first)
    }
}