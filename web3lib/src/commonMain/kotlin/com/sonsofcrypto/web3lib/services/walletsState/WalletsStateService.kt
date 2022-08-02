package com.sonsofcrypto.web3lib.services.walletsState

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.signer.Wallet
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.BigInt

interface WalletsStateService {

    fun balance(wallet: Wallet, currency: Currency): BigInt
    fun blockNumber(wallet: Wallet): BigInt

    sealed class Event() {
        data class Balance(
            val wallet: Wallet,
            val currency: Currency,
            val balance: BigInt,
        ): Event()

        data class BlockUpdated(val wallet: Wallet, val number: BigInt): Event()
    }

    interface Listener{ fun handle(event: Event) }

    fun add(listener: Listener, wallet: Wallet, currencies: List<Currency>, )
    /** if listener is null, removes all listeners */
    fun remove(listener: Listener?, wallet: Wallet? = null, )
}

class DefaultWalletsStateService: WalletsStateService {

    private var blocks: MutableMap<String, BigInt> = mutableMapOf()
    private var balances: MutableMap<String, BigInt> = mutableMapOf()
    private var listeners: List<WalletsStateService.Listener> = listOf()

    private val store: KeyValueStore

    constructor(store: KeyValueStore) {
        this.store = store
    }

    override fun balance(wallet: Wallet, currency: Currency): BigInt {
        return balances[balanceId(wallet, wallet.provider()?.network, currency)] ?: BigInt.zero()
    }

    override fun blockNumber(wallel: Wallet): BigInt {
        return blocks[blockId(wallel, wallel.provider()?.network)] ?: BigInt.zero()
    }

    override fun add(
        listener: WalletsStateService.Listener,
        wallet: Wallet,
        currencies: List<Currency>
    ) {

    }

    override fun remove(
        listener: WalletsStateService.Listener?,
        wallet: Wallet?,
    ) {

    }

    private fun emit(event: WalletsStateService.Event) {

    }

    fun update() {
//        for (network in networks) {
//            for (currency in currencies) {
//
//            }
//        }
    }

    private fun balanceId(wallet: Wallet, network: Network?, currency: Currency): String {
        return "balance-${wallet.id()}-${network?.chainId}-${currency.id()}"
    }

    private fun blockId(wallet: Wallet, network: Network?): String {
        return "blockId-${wallet.id()}-${network?.chainId}"
    }
}