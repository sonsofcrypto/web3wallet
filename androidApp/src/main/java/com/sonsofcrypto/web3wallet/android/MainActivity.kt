package com.sonsofcrypto.web3wallet.android

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.sonsofcrypto.web3lib.utils.BundledAssetProviderApplication
import com.sonsofcrypto.web3lib.utils.FileManager
import com.sonsofcrypto.web3lib.utils.secureRand


class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        BundledAssetProviderApplication.setInstance(application)

        setContentView(R.layout.activity_main)

        val tv: TextView = findViewById(R.id.text_view)
        tv.text = secureRand(128).toString()
        println("what in the world")
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
        println("WTF")
//        MultiCallTests().runAll()
        val fm = FileManager()
        val filesDir = getFilesDir()
        println("Absolute ${filesDir.absolutePath}")
        try {
            fm.writeWorkspaceSync("Testing".toByteArray(), "test.txt")
            val result = fm.readWorkspaceSync("test.txt").decodeToString()
            print("RESULT $result")
        } catch (err: Throwable) {
            println("FAILED $err")
        }


        println("=== all tests executed ===")

    }
}

