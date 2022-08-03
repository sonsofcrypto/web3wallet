package com.sonsofcrypto.web3lib.services.walletsState

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.provider.model.QuantityHexString
import com.sonsofcrypto.web3lib.provider.model.toBigIntQnt
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.invoke
import kotlinx.coroutines.launch
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

    fun add(
        listener: WalletsStateListener,
        wallet: Wallet,
        currencies: List<Currency>,
    )

    /** if listener is null, removes all listeners */
    fun remove(listener: WalletsStateListener?, wallet: Wallet? = null)
}

class DefaultWalletsStateService: WalletsStateService {
    private var blocks: MutableMap<String, BigInt> = mutableMapOf()
    private var balances: MutableMap<String, BigInt> = mutableMapOf()
    private var listeners: MutableSet<WalletsStateListener>
    private var listenerWallets: MutableMap<WalletsStateListener, MutableSet<Wallet>>
    private var listenerWalletCurrencies: MutableMap<String, MutableSet<Currency>>
    private val bgScope = CoroutineScope(SupervisorJob() + bgDispatcher)
    private val mainScope = CoroutineScope(SupervisorJob() + uiDispatcher)
    private val store: KeyValueStore

    constructor(store: KeyValueStore) {
        this.store = store
        this.listeners = mutableSetOf()
        this.listenerWallets = mutableMapOf()
        this.listenerWalletCurrencies = mutableMapOf()
    }

    init { setupFlows() }

    override fun balance(wallet: Wallet, currency: Currency): BigInt {
        return balances[balanceId(wallet, wallet.provider()?.network, currency)] ?: BigInt.zero()
    }

    override fun blockNumber(wallel: Wallet): BigInt? {
        val id = blockId(wallel, wallel.provider()?.network)
        return blocks[id] ?: store.get<QuantityHexString>(id)?.toBigIntQnt()
    }

    private fun setBlockNumber(wallet: Wallet, blockNumber: BigInt?) {
        val id = blockId(wallet, wallet.network())
        val number = blockNumber(wallet) ?: blocks[id]
        if (number != null) {
            blocks[id] = number
            store.set(id, QuantityHexString(number))
        } else {
            blocks.remove(id)
            store.set(id, null)
        }
    }

    override fun add(
        listener: WalletsStateListener,
        wallet: Wallet,
        currencies: List<Currency>
    ) {
        listeners.add(listener)

        val listerWallets = listenerWallets[listener] ?: mutableSetOf()
        listerWallets.add(wallet)
        listenerWallets[listener] = listerWallets

        val listenerId = listenerId(listener, wallet)
        val currencies = listenerWalletCurrencies[listenerId] ?: mutableSetOf()
        currencies.addAll(currencies)
        listenerWalletCurrencies[listenerId] = currencies
    }

    override fun remove(
        listener: WalletsStateListener?,
        wallet: Wallet?,
    ) {
        if (listener != null && wallet != null) {
            val listenerId = listenerId(listener, wallet)
            listenerWalletCurrencies[listenerId] = mutableSetOf()
            return
        }
        if (listener != null) {
            listenerWallets[listener] = mutableSetOf()
            return
        }
        listeners = mutableSetOf()
        listenerWallets = mutableMapOf()
        listenerWalletCurrencies = mutableMapOf()
    }

    private fun emit(event: WalletsStateEvent) = when(event){
        is WalletsStateEvent.BlockNumber -> {
            listeners.forEach {
                if (listenerWallets[it]?.contains(event.wallet) == true)
                    it.handle(event)
            }
        }
        is WalletsStateEvent.Balance -> {

        }
    }

    private suspend fun performLoop() = mainScope.launch {
        if (listeners.isEmpty())
            return@launch

        println("=== performLoop ${currentThreadId()}")

        val allWallet: Set<Wallet> = listeners
            .map { listenerWallets[it] }
            .mapNotNull { it }
            .reduce { acc, s ->  (acc + s).toMutableSet() }

        bgScope.launch {
            blockNumbers(allWallet)
        }
    }

    private suspend fun blockNumbers(wallets: Set<Wallet>) = bgDispatcher {
        for (wallet in wallets) {
            println("=== blockNumbers before block ${currentThreadId()}")
            val block = wallet.provider()?.blockNumber()
            println("=== blockNumber after block $block ${currentThreadId()}")
            handleBlockNumber(wallet, block)
        }
    }

    private suspend fun handleBlockNumber(
        wallet: Wallet,
        blockNumber: BigInt?
    ) = uiDispatcher {
        println("=== handleBlockNumber $blockNumber ${currentThreadId()}")
        setBlockNumber(wallet, blockNumber)
        if (blockNumber != null) {
            emit(WalletsStateEvent.BlockNumber(wallet, blockNumber))
        }
    }

    @OptIn(ExperimentalTime::class)
    private fun setupFlows() {
        timerFlow(refreshInterval)
            .onEach { performLoop() }
            .launchIn(bgScope)
    }

    private fun listenerId(listener: WalletsStateListener, wallet: Wallet): String {
        return "listenerId-${wallet.id()}-${wallet.provider()?.network}"
    }

    private fun balanceId(wallet: Wallet, network: Network?, currency: Currency): String {
        return "balance-${wallet.id()}-${network?.chainId}-${currency.id()}"
    }

    private fun blockId(wallet: Wallet, network: Network?): String {
        return "blockId-${wallet.id()}-${network?.chainId}"
    }
}