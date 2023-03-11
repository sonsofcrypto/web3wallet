package com.sonsofcrypto.web3wallet.android

import android.content.Context
import android.os.Bundle
import android.view.WindowManager
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.BundledAssetProviderApplication
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3wallet.android.common.Assembler
import com.sonsofcrypto.web3wallet.android.common.DefaultAssembler
import com.sonsofcrypto.web3wallet.android.common.MainBootstrapper
import com.sonsofcrypto.web3walletcore.extensions.App
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
        window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN)

        setContentView(R.layout.activity_main)

        if (savedInstanceState == null) {
            MainBootstrapper(this).boot()
        }

         bootServices()

        //val tv: TextView = findViewById(R.id.text_view)
        //tv.text = secureRand(128).toString()
    }

    private fun bootServices() {
        val walletService: WalletService = assembler.resolve(WalletService::class.name)
        val currencyStoreService: CurrencyStoreService = assembler.resolve(
            CurrencyStoreService::class.name
        )
        //tval nftsService: NFTsService = assembler.resolve(NFTsService::class.name)
        val allCurrencies = walletService.networks()
            .map { walletService.currencies(it) }
            .reduce { total, it -> total + it }

        if (allCurrencies.isEmpty()) { return }

        bgScope.launch {
            currencyStoreService.fetchMarketData(allCurrencies)
            //nftsService.fetchNFTs()
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

