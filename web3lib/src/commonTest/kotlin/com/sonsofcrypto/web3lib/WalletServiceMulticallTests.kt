package com.sonsofcrypto.web3lib

import com.sonsofcrypto.web3lib.keyValueStore.KeyValueStore
import com.sonsofcrypto.web3lib.services.currencyStore.defaultCurrencies
import com.sonsofcrypto.web3lib.services.poll.DefaultPollService
import com.sonsofcrypto.web3lib.services.wallet.DefaultWalletServiceMulticall
import com.sonsofcrypto.web3lib.services.wallet.WalletEvent
import com.sonsofcrypto.web3lib.services.wallet.WalletListener
import com.sonsofcrypto.web3lib.types.Network
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.time.Duration.Companion.seconds

class WalletServiceMulticallTests: WalletListener {

    @Test
    fun testPooling() = runBlocking {
        println("[WalletServiceMulticallTests] start")
        val prefix = "walletServiceMulticallTests"
        val services = testEnvServices(prefix)
        val networksService = testEnvNetworkService(prefix)
        services.networksService.network = Network.ethereum()
        services.networksService.setNetwork(Network.goerli(), true)
        services.networksService.setNetwork(Network.sepolia(), true)
        val walletService = DefaultWalletServiceMulticall(
            services.networksService,
            services.currencyStoreService,
            DefaultPollService(),
            KeyValueStore("$prefix.walletService.currencies"),
            KeyValueStore("$prefix.walletService.networkState"),
            KeyValueStore("$prefix.walletService.transferLogCache"),
        )
        services.networksService.enabledNetworks().forEach {
            services.networksService.provider(it).debugLogs = true
            walletService.setCurrencies(defaultCurrencies(it), it)
        }
        walletService.add(this@WalletServiceMulticallTests)
        walletService.startPolling()
        delay(60.seconds)
    }

    override fun handle(event: WalletEvent) {
        if ((event as? WalletEvent.Balance) != null) {
            println("Network: ${event.network.name} ${event.network.chainId} - ${event.currency.name} ${event.balance.toDecimalString()} ")
        } else {
            println("[WalletServiceMulticallTests] $event")
        }
    }

}
