package com.sonsofcrypto.web3lib.services.wallet

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.provider.model.*
import com.sonsofcrypto.web3lib.services.currencyStore.*
import com.sonsofcrypto.web3lib.services.networks.NetworksEvent
import com.sonsofcrypto.web3lib.services.networks.NetworksEvent.EnabledNetworksDidChange
import com.sonsofcrypto.web3lib.services.networks.NetworksListener
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.signer.contracts.ERC20
import com.sonsofcrypto.web3lib.types.*
import com.sonsofcrypto.web3lib.utils.*
import com.sonsofcrypto.web3lib.utils.extensions.jsonDecode
import com.sonsofcrypto.web3lib.utils.extensions.jsonEncode
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlin.time.Duration.Companion.seconds

/** `WalletService` higher level "manager" wallet state manager. Should suffice
 * for majority of basic usecases. For more fine grained control use `Wallet`.
 * `WalletService` tracks state of wallet for all enabled networks. Periodically
 * fetches and emits events about relevant data like block and balances, etc.
 * Picks up changes about enabled networks and providers from `NetworksService`
 * Allows for easy transfers of crypto assets.
 */
interface WalletService {
    /** Currently selected network. See `NetworksService.network` */
    fun selectedNetwork(): Network?
    /** All currently enabled networks. See `NetworksService.enabledNetworks()` */
    fun networks(): List<Network>

    /** Tracked currencies for network */
    fun currencies(network: Network): List<Currency>
    /** Set tracked currencies for network */
    fun setCurrencies(currencies: List<Currency>, network: Network)

    /** Address for network */
    fun address(network: Network): AddressHexString?
    /** Last known balance number for network connected to wallet  */
    fun balance(network: Network, currency: Currency): BigInt
    /** Last known block number for network connected to wallet  */
    fun blockNumber(network: Network): BigInt
    /** Last known transaction count wallet (in network wallet is connected to) */
    fun transactionCount(network: Network): BigInt
    /** Transfer logs for ERC20 only. Always empty for native */
    fun transferLogs(currency: Currency, network: Network): List<Log>

    /** Retrieves private key from secure storage for 5 secs. */
    @Throws(Throwable::class)
    fun unlock(password: String, salt: String, network: Network)
    /** Transfers native currency or ERC20 token. Must call unlock wallet prior */
    @Throws(Throwable::class)
    suspend fun transfer(
        to: AddressHexString,
        currency: Currency,
        amount: BigInt,
        network: Network
    ): TransactionResponse
    /** Call smart contract function */
    @Throws(Throwable::class)
    suspend fun contractSend(
        contractAddress: AddressHexString,
        data: DataHexString,
        network: Network
    ): TransactionResponse
    /** Transfer logs for ERC20 only. Always empty for native */
    @Throws(Throwable::class)
    suspend fun fetchTransferLogs(currency: Currency, network: Network): List<Log>

    /** Begins polling networks events */
    fun startPolling()
    /** Pauses pooling of network events */
    fun pausePolling()

    /** Add listener for `WalletEvent`s */
    fun add(listener: WalletListener)
    /** Remove listener for `WalletEvent`s, if null removes all listeners */
    fun remove(listener: WalletListener?)
}

private val pollInterval = 15.seconds

class DefaultWalletService(
    private val networkService: NetworksService,
    private val currencyStoreService: CurrencyStoreService,
    private val currenciesCache: KeyValueStore,
    private val networksStateCache: KeyValueStore,
    private val transferLogsCache: KeyValueStore
): WalletService, NetworksListener {
    private val currencies: MutableMap<String, List<Currency>> = mutableMapOf()
    private val networksState: MutableMap<String, BigInt> = mutableMapOf()
    private val transferLogs: MutableMap<String, List<Log>> = mutableMapOf()
    private val transferLogsNonce: MutableMap<String,BigInt> = mutableMapOf()
    private var listeners: MutableSet<WalletListener> = mutableSetOf()
    private var pending: MutableMap<String, List<TransactionResponse>> = mutableMapOf()
    private var pollingJob: Job? = null
    private val scope = CoroutineScope(SupervisorJob() + bgDispatcher)

    init {
        networkService.add(this)
    }

    override fun selectedNetwork(): Network? = networkService.network

    override fun networks(): List<Network> = networkService.enabledNetworks()

    override fun currencies(network: Network): List<Currency> {
        val key = "${network.id()}_${networkService.wallet(network)?.id()}"
        currencies[key]?.let { return it }
        currenciesCache.get<String>(key)?.let {
            jsonDecode<List<Currency>>(it)?.let { curr -> return curr }
        }
        setCurrencies(defaultCurrencies(network), network)
        return defaultCurrencies(network)
    }

    override fun setCurrencies(currencies: List<Currency>, network: Network) {
        val key = "${network.id()}_${networkService.wallet(network)?.id()}"
        this.currencies[key] = currencies
        currenciesCache.set(key, jsonEncode(currencies))
        emit(WalletEvent.Currencies(network, currencies))
        currencyStoreService.cacheMetadata(currencies)
    }

    override fun address(network: Network): AddressHexString? {
        return networkService.wallet(network)?.address()?.toHexString()
    }

    override fun balance(network: Network, currency: Currency): BigInt {
        networksState[balanceKey(network, currency)]?.let { return it }
        networksStateCache.get<String>(balanceKey(network, currency))?.let {
            jsonDecode<BigInt>(it)?.let { balance -> return balance }
        }
        return BigInt.zero()
    }

    override fun blockNumber(network: Network): BigInt {
        networksState[blockNumKey(network)]?.let { return it }
        networksStateCache.get<String>(blockNumKey(network))?.let {
            jsonDecode<BigInt>(it)?.let { blockNumber -> return blockNumber }
        }
        return BigInt.zero()
    }

    override fun transactionCount(network: Network): BigInt {
        networksState[transactionCountKey(network)]?.let { return it }
        networksStateCache.get<String>(transactionCountKey(network))?.let {
            jsonDecode<BigInt>(it)?.let { balance -> return balance }
        }
        return BigInt.zero()
    }

    override fun transferLogs(currency: Currency, network: Network): List<Log> {
        transferLogs[transferLogsKey(currency, network)]?.let { return it }
        transferLogsCache.get<String>(transferLogsKey(currency, network))?.let {
            jsonDecode<List<Log>>(it)?.let { logs -> return logs }
        }
        return listOf()
    }

    private fun addPending(
        response: TransactionResponse,
        currency: Currency,
        network: Network
    ) {
        val key = pendingKey(currency, network)
        pending[key] = (pending[key] ?: listOf()) + listOf(response)
    }


    override fun unlock(password: String, salt: String, network: Network) {
        networkService.wallet(network)?.unlock(password, salt)
    }

    @Throws(Throwable::class)
    override suspend fun transfer(
        to: AddressHexString,
        currency: Currency,
        amount: BigInt,
        network: Network
    ): TransactionResponse = withBgCxt {
        val request = transferTransactionRequest(to, currency, amount)
        val wallet = networkService.wallet(network)
        val response = wallet!!.sendTransaction(request)
        withUICxt {
            addPending(response, currency, network)
            emit(WalletEvent.NewPendingTransaction(response.hash))
        }
        return@withBgCxt response
    }

    @Throws(Throwable::class)
    override suspend fun contractSend(
        contractAddress: AddressHexString,
        data: DataHexString,
        network: Network
    ): TransactionResponse = withBgCxt {
        val request = TransactionRequest(
            to = Address.HexString(contractAddress),
            data = data
        )
        val wallet = networkService.wallet(network)
        val response = wallet!!.sendTransaction(request)
        withUICxt {
            emit(WalletEvent.NewPendingTransaction(response.hash))
        }
        return@withBgCxt response
    }

    @Throws(Throwable::class)
    private fun transferTransactionRequest(
        to: AddressHexString,
        currency: Currency,
        amount: BigInt
    ): TransactionRequest {
        if (currency.type == Currency.Type.NATIVE)
            return TransactionRequest(to = Address.HexString(to), value = amount)
        if (currency.type == Currency.Type.ERC20 && currency.address != null)
            return TransactionRequest(
                to = Address.HexString(currency.address!!),
                data = ERC20(Address.HexString(currency.address!!))
                    .transfer(Address.HexString(to), amount)
            )
        throw Error.UnableToSendTransaction
    }

    @Throws(Throwable::class)
    override suspend fun fetchTransferLogs(
        currency: Currency,
        network: Network
    ): List<Log> = withBgCxt {
        val wallet = withUICxt { return@withUICxt networkService.wallet(network) }
        val nonce = withUICxt { return@withUICxt transactionCount(network) }
        val lastNonce = withUICxt { return@withUICxt transferLogNonce(currency, network) }
        if (nonce == lastNonce) {
            val logs = withUICxt { transferLogs(currency, network) }
            return@withBgCxt logs
        }
        val logs = wallet?.getTransferLogs(currency) ?: listOf()
        withUICxt {
            val key = transferLogsKey(currency, network)
            val nonceKey = transferLogsNonceKey(currency, network)
            transferLogs[key] = logs
            transferLogsNonce[nonceKey] = transactionCount(network)
            transferLogsCache.set(key, jsonEncode(logs))
            transferLogsCache.set(nonceKey, jsonEncode(transactionCount(network)))
            emit(WalletEvent.TransferLogs(currency, logs))
        }
        return@withBgCxt logs
    }

    private fun transferLogNonce(currency: Currency, network: Network): BigInt {
        transferLogsNonce[transferLogsNonceKey(currency, network)]?.let { return it }
        transferLogsCache.get<String>(transferLogsNonceKey(currency, network))?.let {
            jsonDecode<BigInt>(it)?.let { nonce -> return nonce }
        }
        return BigInt.zero()
    }

    override fun add(listener: WalletListener) {
        listeners.add(listener)
    }

    override fun remove(listener: WalletListener?) {
        if (listener != null) listeners.remove(listener)
        else listeners = mutableSetOf()
    }

    private fun emit(event: WalletEvent) = listeners.forEach { it.handle(event)}

    override fun handle(event: NetworksEvent) {
        when (event) {
            NetworksEvent.KeyStoreItemDidChange,
            is EnabledNetworksDidChange -> startPolling()
            else -> {}
        }
    }

    override fun startPolling() {
        if (pollingJob == null)
            pollingJob = timerFlow(pollInterval)
                .onEach { poll() }
                .launchIn(scope)
    }

    override fun pausePolling() {
        pollingJob?.cancel()
        pollingJob = null
    }

    private suspend fun poll() = withContext(SupervisorJob() + uiDispatcher) {
        val wallets = networks().map { networkService.wallet(it) }
        val transactionCounts = networks().map { transactionCount(it) }
        val currencies = networks().map { currencies(it) }
        val pending = pending.toMap()
        scope.launch(logExceptionHandler) {
            wallets.forEachIndexed { idx, wallet ->
                if (wallet != null) {
                    blockNumber(wallet)
                    transactionCountAndBalance(
                        wallet,
                        transactionCounts[idx],
                        currencies[idx]
                    )
                }
            }
            processPending(pending)
        }
    }

    private suspend fun blockNumber(wallet: Wallet) {
        val network = wallet.network()!!
        val block = wallet.provider()?.blockNumber() ?: BigInt.zero()
        withUICxt {
            networksState[blockNumKey(network)] = block
            networksStateCache.set(blockNumKey(network), jsonEncode(block))
            emit(WalletEvent.BlockNumber(network, block))
        }
    }

    private suspend fun transactionCountAndBalance(
        wallet: Wallet,
        transactionCount: BigInt,
        currencies: List<Currency>
    ) {
        val newTransactionCount = wallet.getTransactionCount(
            wallet.address(),
            BlockTag.Latest
        )
        if (transactionCount == newTransactionCount)
            return
        // TODO: Get transaction from nonce and only update IRC20s in transaction
        currencies.forEach { currency ->
            when (currency.type) {
                Currency.Type.NATIVE -> {
                    val balance = wallet.getBalance(BlockTag.Latest)
                    updateBalance(wallet, currency, balance, newTransactionCount)
                }
                Currency.Type.ERC20 -> {
                    val contract = ERC20(Address.HexString(currency.address!!))
                    val address = wallet.address().toHexStringAddress()
                    val encodedBalance = wallet.call(
                        TransactionRequest(
                            to = contract.address,
                            data = contract.balanceOf(address),
                        )
                    )
                    val balance = abiDecodeBigInt(encodedBalance)
                    updateBalance(wallet, currency, balance, newTransactionCount)
                }
                else -> { println("Unhandled balance") }
            }
        }
    }

    private suspend fun processPending(pending: Map<String, List<TransactionResponse>>) {
        val remaining: MutableMap<String, List<TransactionResponse>> = mutableMapOf()
        val processed: MutableMap<String, List<TransactionReceipt>> = mutableMapOf()
        for ((key, value) in pending) {
            println("$key = $value")
        }

    }

    private suspend fun updateBalance(
        wallet: Wallet,
        currency: Currency,
        balance: BigInt,
        transactionCount: BigInt
    ) = withUICxt {
        val network = wallet.network()!!
        networksState[balanceKey(network, currency)] = balance
        networksState[transactionCountKey(network)] = transactionCount
        networksStateCache.set(
            balanceKey(network, currency), jsonEncode(balance)
        )
        networksStateCache.set(
            transactionCountKey(network), jsonEncode(transactionCount)
        )
        emit(WalletEvent.TransactionCount(network, transactionCount))
        emit(WalletEvent.Balance(network, currency, balance))
    }

    private fun blockNumKey(network: Network): String {
        return "blockNumber_${network.id()}"
    }

    private fun balanceKey(network: Network, currency: Currency): String {
        return "balanace_${network.id()}_${currency.id()}"
    }

    private fun transactionCountKey(network: Network): String {
        return "transactionCount_${network.id()}"
    }

    private fun pendingKey(currency: Currency, network: Network): String {
        return "pending_${currency.id()}_${network.id()}"
    }

    private fun transferLogsKey(currency: Currency, network: Network): String {
        return "transferLogs_${currency.id()}_${network.id()}"
    }

    private fun transferLogsNonceKey(currency: Currency, network: Network): String {
        return "transferLogsNonce_${currency.id()}_${network.id()}"
    }

    private fun defaultCurrencies(network: Network): List<Currency> {
        return when (network) {
            Network.ethereum() -> ethereumDefaultCurrencies
            Network.ropsten() -> ropstenDefaultCurrencies
            Network.rinkeby() -> rinkebyDefaultCurrencies
            Network.goerli() -> goerliDefaultCurrencies
            else -> emptyList()
        }
    }

    /** Errors */
    sealed class Error(
        message: String? = null,
        cause: Throwable? = null
    ) : Throwable(message, cause) {

        constructor(cause: Throwable) : this(null, cause)

        /** Unable to sent transactions */
        object UnableToSendTransaction : Error("Unable to sent transactions")
    }
}
