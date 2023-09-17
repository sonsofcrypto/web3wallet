package com.sonsofcrypto.web3lib.services.wallet

import com.sonsofcrypto.web3lib.contract.ERC20
import com.sonsofcrypto.web3lib.contract.Interface
import com.sonsofcrypto.web3lib.contract.Multicall3
import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.provider.model.*
import com.sonsofcrypto.web3lib.services.currencyStore.*
import com.sonsofcrypto.web3lib.services.networks.NetworksEvent
import com.sonsofcrypto.web3lib.services.networks.NetworksEvent.EnabledNetworksDidChange
import com.sonsofcrypto.web3lib.services.networks.NetworksListener
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.poll.FnPollServiceRequest
import com.sonsofcrypto.web3lib.services.poll.PollService
import com.sonsofcrypto.web3lib.services.poll.PollServiceRequest
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.signer.contracts.ERC20Legacy
import com.sonsofcrypto.web3lib.types.*
import com.sonsofcrypto.web3lib.utils.*
import com.sonsofcrypto.web3lib.utils.extensions.jsonDecode
import com.sonsofcrypto.web3lib.utils.extensions.jsonEncode
import kotlinx.coroutines.*
import kotlin.time.Duration
import kotlin.time.Duration.Companion.seconds


class DefaultWalletServiceMulticall(
    private val networkService: NetworksService,
    private val currencyStoreService: CurrencyStoreService,
    private val pollService: PollService,
    private val currenciesCache: KeyValueStore,
    private val networksStateCache: KeyValueStore,
    private val transferLogsCache: KeyValueStore
): WalletService, NetworksListener {
    private val currencies: MutableMap<String, List<Currency>> = mutableMapOf()
    private val networksState: MutableMap<String, BigInt> = mutableMapOf()
    private val transferLogs: MutableMap<String, List<Log>> = mutableMapOf()
    private val transferLogsNonce: MutableMap<String,BigInt> = mutableMapOf()
    private var listeners: MutableSet<WalletListener> = mutableSetOf()
    private var pending: MutableList<PendingInfo> = mutableListOf()
    private var requestsIds: List<String> = mutableListOf()
    private var nonSelectedRefreshCounter = 0
    private val nonSelectedRefreshTimeout = 2
    private val scope = CoroutineScope(SupervisorJob() + bgDispatcher)
    private val ifaceERC20 = Interface.ERC20()
    private val ifaceMulticall = Interface.Multicall3()

    init {
        networkService.add(this)
        startPolling()
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
        return BigInt.zero
    }

    override fun blockNumber(network: Network): BigInt {
        networksState[blockNumKey(network)]?.let { return it }
        networksStateCache.get<String>(blockNumKey(network))?.let {
            jsonDecode<BigInt>(it)?.let { blockNumber -> return blockNumber }
        }
        return BigInt.zero
    }

    override fun transactionCount(network: Network): BigInt {
        networksState[transactionCountKey(network)]?.let { return it }
        networksStateCache.get<String>(transactionCountKey(network))?.let {
            jsonDecode<BigInt>(it)?.let { balance -> return balance }
        }
        return BigInt.zero
    }

    override fun pendingTransactions(network: Network): List<PendingInfo> {
        return pending.filter { it.network.id() == network.id() }
    }

    override fun pendingTransactions(
        network: Network,
        currency: Currency
    ): List<PendingInfo> = pending.filter {
        it.network.id() == network.id()
                && it as? PendingInfo.Transfer != null
                && it.currency.id() == currency.id()
    }

    private fun recordedTransactionCount(network: Network): BigInt? {
        networksState[transactionCountKey(network)]?.let { return it }
        networksStateCache.get<String>(transactionCountKey(network))?.let {
            jsonDecode<BigInt>(it)?.let { balance -> return balance }
        }
        return null
    }

    override fun transferLogs(currency: Currency, network: Network): List<Log> {
        transferLogs[transferLogsKey(currency, network)]?.let { return it }
        transferLogsCache.get<String>(transferLogsKey(currency, network))?.let {
            jsonDecode<List<Log>>(it)?.let { logs -> return logs }
        }
        return listOf()
    }

    private fun addPending(info: PendingInfo) {
        pending.add(info)
        emit(WalletEvent.NewPendingTransaction(info))
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
            addPending(PendingInfo.Transfer(network, currency, to, amount, response))
            scheduleUpdate(3.seconds)
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
            addPending(PendingInfo.Contract(network, contractAddress, response))
            scheduleUpdate(3.seconds)
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
                data = ERC20Legacy(Address.HexString(currency.address!!))
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
            emit(WalletEvent.TransferLogs(network, currency, logs))
        }
        return@withBgCxt logs
    }


    private fun transferLogNonce(currency: Currency, network: Network): BigInt {
        transferLogsNonce[transferLogsNonceKey(currency, network)]?.let { return it }
        transferLogsCache.get<String>(transferLogsNonceKey(currency, network))?.let {
            jsonDecode<BigInt>(it)?.let { nonce -> return nonce }
        }
        return BigInt.zero
    }

    override fun reloadAllBalances() {
        println("[WalletService2] reloadAllBalances NOOP")
    }

    override fun startPolling() {
        invalidatePollRequests(true)
    }

    override fun pausePolling() {
        invalidatePollRequests(false)
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
            is EnabledNetworksDidChange -> {
                pausePolling()
                startPolling()
            }
            else -> {}
        }
    }

    private suspend fun processPending(
        pendingTransactions: List<PendingInfo>,
        wallets: Map<String, Wallet?>
    ) {
        val remaining: MutableList<PendingInfo> = mutableListOf()
        val receipts: MutableList<ReceiptInfo> = mutableListOf()
        for (info in pendingTransactions) {
            val wallet = wallets[info.network.id()]
            if (wallet != null) {
                try {
                    val receipt = wallet.getTransactionReceipt(info.response.hash)
                    receipts.add(info.toReceiptInfo(receipt))
                } catch (error: Throwable) {
                    remaining.add(info)
                    println("=== Receipt error")
                }
            } else {
                remaining.add(info)
            }
        }
        withUICxt {
            pending = remaining
            receipts.forEach { emit(WalletEvent.TransactionReceipt(it)) }
        }
    }

    private fun scheduleUpdate(duration: Duration) {
        scope.launch {
            delay(duration)
//            poll()
            // TODO: Investigate
        }
    }

    private data class BalanceReqUserInfo(
        val network: Network,
        val currency: Currency,
    )

    /** Updates getEthBalance & ERC20 balances. Triggers transaction log fetch
     * if new balance != previous balance. Processes pending transactions */
    private fun poll3() {
        // TODO: That we dont have request pending schedule if we do not
        // TODO: Check if pending transactions were processed
        val requestsIds = mutableListOf<String>()
        for (network in networkService.enabledNetworks()) {
            val wallet = networkService.wallet(network) ?: continue
            val currencies = currencies(network)
            val requests = balancesRequests(
                currencies,
                wallet.address().toHexStringAddress().hexString,
                network
            )
            requestsIds.addAll(requests.map { it.id })
            pollService.setProvider(networkService.provider(network), network)
            requests.forEach { pollService.add(it, network, true) }
        }
        this.requestsIds = requestsIds
    }

    private fun invalidatePollRequests(restart: Boolean) {
        requestsIds.forEach { pollService.cancel(it) }
        if (restart) poll3()
    }

    @Throws(Throwable::class)
    private fun balancesRequests(
        currencies: List<Currency>,
        walletAddress: String,
        network: Network
    ): List<PollServiceRequest> = currencies.map{
        FnPollServiceRequest(
            id = "${network.name}.${it.name}.balance",
            address = if (it.isNative()) network.multicall3Address()
                else it.address ?: throw Throwable("ERC20 missing address $it"),
            iface = if (it.isNative()) ifaceMulticall else ifaceERC20,
            fnName = if (it.isNative()) "getEthBalance" else "balanceOf",
            values = listOf(walletAddress),
            handler = ::handleBalance,
            userInfo = BalanceReqUserInfo(network, it)
        )
    }

    private fun handleBalance(result: List<Any>, request: PollServiceRequest) {
        scope.launch {
            val userInfo = (request.userInfo as? BalanceReqUserInfo)
                ?: throw Throwable("Expected currency $request, $result")
            val isNative = userInfo.currency.isNative()
            val iface = if (isNative) ifaceMulticall else ifaceERC20
            val balance = iface.decodeFunctionResult(
                iface.function(if (isNative) "getEthBalance" else "balanceOf"),
                result.last() as ByteArray
            ).first() as BigInt
            updateBalance(userInfo.network, userInfo.currency, balance)
        }
    }

    private suspend fun updateBalance(
        network: Network,
        currency: Currency,
        balance: BigInt,
    ) = withUICxt {
        val balanceKey = balanceKey(network, currency)
        networksState[balanceKey] = balance
        networksStateCache.set(balanceKey, jsonEncode(balance))
        // TODO: Only emit if balance changed
        emit(WalletEvent.Balance(network, currency, balance))
        // TODO: Trigger logs fetch if needed
    }

        /** Network service begining ============*/

//    private var pollRequest: PollServiceRequest? = null
//    private var nonSelectedRefreshCounter = 0
//    private val nonSelectedRefreshTimeout = 2
//
//    private fun updatePollingLoop() {
//        pollRequest?.let { pollService.cancel(it.id) }
//        if (!enabledNetworks.contains(network)) return
//        val network = this.network ?: return
//        val request = GroupPollServiceRequest(
//            "NetworkInfo.${network.name} - ${Clock.System.now().epochSeconds}",
//            NetworkInfo.calls(network.multicall3Address()),
//            ::handleNetworkInfo,
//            network
//        )
//        pollService.setProvider(provider(network), network)
//        pollService.add(request, network, true)
//        pollRequest = request
//    }
//
//    private fun handleNetworkInfo(
//        result: List<Any>,
//        request: PollServiceRequest
//    ) {
//        val networkInfo = NetworkInfo.decodeCallData(result as List<List<Any>>)
//        setNetworkInfo(networkInfo, request.userInfo as Network)
//        if (network == request.userInfo as Network)
//            fetchNonSelectedNetwokrsInfo()
//    }
//
//    private fun fetchNonSelectedNetwokrsInfo() {
//        if (nonSelectedRefreshCounter != 0) {
//            nonSelectedRefreshCounter--
//            return
//        }
//        nonSelectedRefreshCounter = nonSelectedRefreshTimeout
//        enabledNetworks
//            .filter { it != network }
//            .forEach {
//                val request = GroupPollServiceRequest(
//                    "NetworkInfo.${it.name}-${Clock.System.now().epochSeconds}",
//                    NetworkInfo.calls(it.multicall3Address()),
//                    ::handleNetworkInfo,
//                    it
//                )
//                pollService.setProvider(provider(it), it)
//                pollService.add(request, it, false)
//            }
//    }

    /** Network service end =================*/

    /** Old polling service begining ======================================== */

//    override fun startPolling() {
//        if (pollingJob == null)
//            pollingJob = timerFlow(pollInterval, initialDelay = 0.1.seconds)
//                .onEach { poll() }
//                .launchIn(scope)
//    }
//
//    override fun pausePolling() {
//        pollingJob?.cancel()
//        pollingJob = null
//    }
//
//    private suspend fun poll() = withContext(SupervisorJob() + uiDispatcher) {
//        val wallets = networks().map { networkService.wallet(it) }
//        val transactionCounts = networks().map { recordedTransactionCount(it) }
//        val currencies = networks().map { currencies(it) }
//        val pendingTransactions = pending.toList()
//        val walletsMap = networks().map { it.id() to networkService.wallet(it) }
//            .toMap()
//        val force = !didReloadOnLastBlock
//        didReloadOnLastBlock = !didReloadOnLastBlock
//        scope.launch(logExceptionHandler) {
//            processPending(pendingTransactions, walletsMap)
//            wallets.forEachIndexed { idx, wallet ->
//                if (wallet != null) {
//                    blockNumber(wallet)
//                    transactionCountAndBalance(
//                        wallet,
//                        transactionCounts[idx],
//                        currencies[idx],
//                        force
//                    )
//                }
//            }
//        }
//    }
//
//    private suspend fun blockNumber(wallet: Wallet) {
//        val network = wallet.network()!!
//        val block = wallet.provider()?.blockNumber() ?: BigInt.zero
//        withUICxt {
//            networksState[blockNumKey(network)] = block
//            networksStateCache.set(blockNumKey(network), jsonEncode(block))
//            emit(WalletEvent.BlockNumber(network, block))
//        }
//    }
//
//    private suspend fun transactionCountAndBalance(
//        wallet: Wallet,
//        transactionCount: BigInt?,
//        currencies: List<Currency>,
//        force: Boolean = false
//    ) {
//        val newTransactionCount = wallet.getTransactionCount(
//            wallet.address(),
//            BlockTag.Latest
//        )
//        if (!force && transactionCount != null && transactionCount == newTransactionCount)
//            return
//        // TODO: Get transaction from nonce and only update IRC20s in transaction
//        currencies.forEach { currency ->
//            when (currency.type) {
//                Currency.Type.NATIVE -> {
//                    val balance = wallet.getBalance(BlockTag.Latest)
//                    updateBalance(wallet, currency, balance, newTransactionCount)
//                }
//                Currency.Type.ERC20 -> {
//                    val contract = ERC20Legacy(Address.HexString(currency.address!!))
//                    val address = wallet.address().toHexStringAddress()
//                    val encodedBalance = wallet.call(
//                        TransactionRequest(
//                            to = contract.address,
//                            data = contract.balanceOf(address),
//                        )
//                    )
//                    val balance = abiDecodeBigInt(encodedBalance)
//                    updateBalance(wallet, currency, balance, newTransactionCount)
//                }
//                else -> { println("Unhandled balance") }
//            }
//        }
//    }
//
//    override fun reloadAllBalances() {
//        val wallets = networks().map { networkService.wallet(it) }
//        val transactionCounts = networks().map { recordedTransactionCount(it) }
//        val currencies = networks().map { currencies(it) }
//        didReloadOnLastBlock = true
//        scope.launch(logExceptionHandler) {
//            wallets.forEachIndexed { idx, wallet ->
//                if (wallet != null) {
//                    blockNumber(wallet)
//                    transactionCountAndBalance(
//                        wallet,
//                        transactionCounts[idx],
//                        currencies[idx],
//                        true
//                    )
//                }
//            }
//        }
//    }

    /** Old polling service end ============================================= */

    private fun blockNumKey(network: Network): String {
        val wallet = networkService.wallet(network)
        return "blockNumber_${wallet?.id()}_${network.id()}"
    }

    private fun balanceKey(network: Network, currency: Currency): String {
        val wallet = networkService.wallet(network)
        return "balanace_${wallet?.id()}_${network.id()}_${currency.id()}"
    }

    private fun transactionCountKey(network: Network): String {
        val wallet = networkService.wallet(network)
        return "transactionCount_${wallet?.id()}_${network.id()}"
    }

    private fun pendingKey(currency: Currency, network: Network): String {
        val wallet = networkService.wallet(network)
        return "pending_${wallet?.id()}_${currency.id()}_${network.id()}"
    }

    private fun transferLogsKey(currency: Currency, network: Network): String {
        val wallet = networkService.wallet(network)
        return "transferLogs_${wallet?.id()}_${currency.id()}_${network.id()}"
    }

    private fun transferLogsNonceKey(currency: Currency, network: Network): String {
        val wallet = networkService.wallet(network)
        return "transferLogsNonce_${wallet?.id()}_${currency.id()}_${network.id()}"
    }

    private fun defaultCurrencies(network: Network): List<Currency> {
        return when (network) {
            Network.ethereum() -> ethereumDefaultCurrencies
            Network.sepolia() -> sepoliaDefaultCurrencies
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
