package com.sonsofcrypto.web3wallet.android

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.sonsofcrypto.web3lib.services.node.DefaultNodeService
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.BundledAssetProviderApplication
import com.sonsofcrypto.web3lib.utils.secureRand

class MainActivity : AppCompatActivity() {

    val nodeService = DefaultNodeService()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        BundledAssetProviderApplication.setInstance(application)

        setContentView(R.layout.activity_main)

        val tv: TextView = findViewById(R.id.text_view)
        tv.text = secureRand(128).toString()

        nodeService.startNode(Network.ethereum())
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
        println("=== all tests executed ===")
    }
}
