package com.sonsofcrypto.web3wallet.android

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.BundledAssetProviderApplication
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3wallet.android.common.*
import com.sonsofcrypto.web3wallet.android.modules.compose.currencysend.CurrencySendWireframeFactory
import com.sonsofcrypto.web3walletcore.extensions.App
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardInteractorEvent
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import smartadapter.internal.extension.name

val assembler: Assembler = DefaultAssembler()
lateinit var appContext: Context

class MainActivity : App() {

    private val bgScope = CoroutineScope(bgDispatcher)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        appContext = this
        BundledAssetProviderApplication.setInstance(application)

        //AppTheme.value = themeMiamiSunriseLight//themeMiamiSunriseDark

        // Test on how to set a new theme
        //setTheme(R.style.Miami_Dark)
        //recreate()

        setContentView(R.layout.activity_main)

        if (savedInstanceState == null) {
            MainBootstrapper(this).boot()
        }

        // bootServices()

        //val tv: TextView = findViewById(R.id.text_view)
        //tv.text = secureRand(128).toString()
    }

    private fun bootServices() {
        val walletService: WalletService = assembler.resolve(WalletService::class.name)
        val currencyStoreService: CurrencyStoreService = assembler.resolve(
            CurrencyStoreService::class.name
        )
        val nftsService: NFTsService = assembler.resolve(NFTsService::class.name)
        val allCurrencies = walletService.networks()
            .map { walletService.currencies(it) }
            .reduce { total, it -> total + it }

        if (allCurrencies.isEmpty()) { return }

        bgScope.launch {
            currencyStoreService.fetchMarketData(allCurrencies)
            nftsService.fetchNFTs()
        }

    }

    override fun onResume() {
        super.onResume()
//        Bip39Test().runAll()
//        Bip44Test().runAll()
//        KeyValueStoreTest().runAll()
//        KeyStoreTest().runAll()
//        TrieTest().runAll()
//        ProviderTest().runAll()
//        CoinGeckoTest(this.applicationContext).runAll()
//        Web3ServiceTests().runAll()
//        CurrenciesServiceTests().runAll()
//        WalletStateTest().runAll()
//        CurrencyFormatterTest().runAll()
//        CurrencyStoreServiceTest().runAll()
//        WalletServiceTest().runAll()
//        UniswapTests().runAll()
//        EncryptTest().runAll()
//        WalletCoreTests().runAll()
//        InterfaceTests().runAll()
//        MultiCallTests().runAll()
        println("=== all tests executed ===")
    }
}

