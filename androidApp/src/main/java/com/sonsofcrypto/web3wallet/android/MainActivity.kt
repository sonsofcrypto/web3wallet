package com.sonsofcrypto.web3wallet.android

import android.content.Context
import android.os.Bundle
import android.view.WindowManager
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.BundledAssetProviderApplication
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3wallet.android.common.*
import com.sonsofcrypto.web3walletcore.app.App
import com.sonsofcrypto.web3walletcore.services.settings.Setting
import com.sonsofcrypto.web3walletcore.services.settings.Setting.Action.*
import com.sonsofcrypto.web3walletcore.services.settings.Setting.Group.THEME
import com.sonsofcrypto.web3walletcore.services.settings.SettingsService
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

        // TODO: Review if this is really needed
        window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN)

        setContentView(R.layout.activity_main)

        if (savedInstanceState == null) {
            MainBootstrapper(this).boot()
        }

        bootServices()
        configureTheme()

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

    private fun configureTheme() {
        val settingsService: SettingsService = assembler.resolve(SettingsService::class.name)
        if (settingsService.isSelected(Setting(THEME, THEME_MIAMI_LIGHT))) {
            AppTheme.value = themeMiamiSunriseLight
        } else if (settingsService.isSelected(Setting(THEME, THEME_MIAMI_DARK))) {
            AppTheme.value = themeMiamiSunriseDark
        } else if (settingsService.isSelected(Setting(THEME, THEME_IOS_LIGHT))) {
            AppTheme.value = themeMiamiSunriseLight
        } else if (settingsService.isSelected(Setting(THEME, THEME_IOS_DARK))) {
            AppTheme.value = themeMiamiSunriseLight
        } else {
            AppTheme.value = themeMiamiSunriseLight
        }
    }

//    override fun onResume() {
//        super.onResume()
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
//        println("=== all tests executed ===")
//    }
}

