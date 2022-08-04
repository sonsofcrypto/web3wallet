package com.sonsofcrypto.web3lib.services.walletsState

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.provider.model.BlockTag
import com.sonsofcrypto.web3lib.provider.model.QuantityHexString
import com.sonsofcrypto.web3lib.provider.model.toBigIntQnt
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.utils.*
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlin.time.Duration.Companion.seconds
import kotlin.time.ExperimentalTime

private val refreshInterval = 15.seconds

sealed class WalletsStateEvent() {

    data class Balance(
        val wallet: Wallet,
        val currency: Currency,
        val balance: BigInt,
    ): WalletsStateEvent()

    data class BlockNumber(
        val wallet: Wallet,
        val number: BigInt
    ): WalletsStateEvent()
}

interface WalletsStateListener { fun handle(event: WalletsStateEvent) }

interface WalletsStateService {
    fun balance(wallet: Wallet, currency: Currency): BigInt
    fun blockNumber(wallet: Wallet): BigInt?
    /** Replaces currencies if any */
    fun observe(wallet: Wallet, currencies: List<Currency>)
    /** If wallet is null removes all wallets */
    fun stopObserving(wallet: Wallet?)
    /** Add listener for all wallets and currencies */
    fun add(listener: WalletsStateListener)
    /** if listener is null, removes all listeners */
    fun remove(listener: WalletsStateListener?)
    /** starts updates loop */
    fun start()
    /** pauses updates loop*/
    fun pause()
}

class DefaultWalletsStateService: WalletsStateService {
    private var blocks: MutableMap<String, BigInt> = mutableMapOf()
    private var balances: MutableMap<String, BigInt> = mutableMapOf()
    private var listeners: MutableSet<WalletsStateListener> = mutableSetOf()
    private var wallets: MutableSet<Wallet> = mutableSetOf()
    private var currencies: MutableMap<String, List<Currency>> = mutableMapOf()
    private val bgScope = CoroutineScope(SupervisorJob() + bgDispatcher)
    private val mainScope = CoroutineScope(SupervisorJob() + uiDispatcher)
    private var updatesTickJob: Job? = null
    private val store: KeyValueStore

    constructor(store: KeyValueStore) {
        this.store = store
    }

    override fun balance(wallet: Wallet, currency: Currency): BigInt {
        val id = balanceId(wallet, currency)
        return balances[id]
            ?: store.get<QuantityHexString>(id)?.toBigIntQnt()
            ?: BigInt.zero()
    }

    private fun setBalance(wallet: Wallet, currency: Currency, balance: BigInt) {
        val id = balanceId(wallet, currency)
        balances[id] = balance
        store.set(id, QuantityHexString(balance))
    }

    override fun blockNumber(wallel: Wallet): BigInt? {
        val id = blockId(wallel)
        return blocks[id] ?: store.get<QuantityHexString>(id)?.toBigIntQnt()
    }

    private fun setBlockNumber(wallet: Wallet, blockNumber: BigInt?) {
        val id = blockId(wallet)
        val number = blockNumber(wallet) ?: blocks[id]
        if (number != null) {
            blocks[id] = number
            store.set(id, QuantityHexString(number))
        } else {
            blocks.remove(id)
            store.set(id, null)
        }
    }

    override fun add(listener: WalletsStateListener) {
        listeners.add(listener)
        start()
    }

    override fun remove(listener: WalletsStateListener?) {
        if (listener != null) {
            listeners.remove(listener)
        } else listeners = mutableSetOf()
        if (listeners.isEmpty()) {
            pause()
        }
    }

    override fun observe(wallet: Wallet, currencies: List<Currency>) {
        wallets.add(wallet)
        this.currencies.put(currenciesId(wallet), currencies)
    }

    override fun stopObserving(wallet: Wallet?) {
        if (wallet != null) {
            wallets.remove(element = wallet)
            currencies.remove(currenciesId(wallet))
        } else {
            wallets = mutableSetOf()
            currencies = mutableMapOf()
        }
    }

    private fun emit(event: WalletsStateEvent) {
        listeners.forEach { it.handle(event) }
    }

    private suspend fun performLoop() = mainScope.launch {
        if (listeners.isEmpty())
            return@launch

        val allWallets = wallets.toList()

        bgScope.launch {
            blockNumbers(allWallets)
        }

        for (wallet in allWallets) {
            currencies[currenciesId(wallet)]?.let {
                bgScope.launch { balances(wallet, it) }
            }
        }
    }

    private suspend fun blockNumbers(wallets: List<Wallet>) = bgDispatcher {
        for (wallet in wallets) {
            val block = wallet.provider()?.blockNumber()
            handleBlockNumber(wallet, block)
        }
    }

    private suspend fun handleBlockNumber(
        wallet: Wallet,
        blockNumber: BigInt?
    ) = uiDispatcher {
        setBlockNumber(wallet, blockNumber)
        if (blockNumber != null) {
            emit(WalletsStateEvent.BlockNumber(wallet, blockNumber))
        }
    }

    private suspend fun balances(wallet: Wallet, currencies: List<Currency>) = bgDispatcher {
        // TODO: Check if nonce is different
        // TODO: Get transaction from nonce and only update IRC20s in transaction
        for (currency in currencies) {
            when (currency.type) {
                Currency.Type.NATIVE -> {
                    val balance = wallet.getBalance(BlockTag.Latest)
                    handleBalance(wallet, currency, balance)
                }
                Currency.Type.ERC20 -> {
                    // TODO: Get ERC20 balance
                }
                else -> { println("Unhandled balance") }
            }
        }
    }

    private suspend fun handleBalance(
        wallet: Wallet,
        currency: Currency,
        balance: BigInt,
    ) = uiDispatcher {
        setBalance(wallet, currency, balance)
        emit(WalletsStateEvent.Balance(wallet, currency, balance))
    }

    @OptIn(ExperimentalTime::class)
    override fun start() {
        if (updatesTickJob != null) {
            return
        }
        updatesTickJob = timerFlow(refreshInterval)
            .onEach { performLoop() }
            .launchIn(bgScope)
    }

    override fun pause() {
        updatesTickJob?.cancel()
        updatesTickJob = null
    }

    private fun listenerId(listener: WalletsStateListener, wallet: Wallet): String {
        return "listenerId-${wallet.id()}-${wallet.network()}"
    }

    private fun balanceId(wallet: Wallet, currency: Currency): String {
        return "balance-${wallet.id()}-${wallet.network()?.chainId}-${currency.id()}"
    }

    private fun blockId(wallet: Wallet): String {
        return "blockId-${wallet.id()}-${wallet.network()?.chainId}"
    }

    private fun currenciesId(wallet: Wallet): String {
        return "currencies-${wallet.id()}-${wallet.network()?.chainId}"
    }
}