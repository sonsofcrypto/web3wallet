package com.sonsofcrypto.web3wallet.android

import android.content.Context
import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.sonsofcrypto.web3lib.types.Bip44
import com.sonsofcrypto.web3lib.types.ExtKey
import com.sonsofcrypto.web3lib.utils.BundledAssetProviderApplication
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.bip39.WordList
import com.sonsofcrypto.web3lib.utils.secureRand
import coreCrypto.*
import java.util.*

class MainActivity : AppCompatActivity() {

    private var geth: Node? = null

    init {
        Timer().scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                geth?.getPeersInfo()?.let {
                    if (it.size() != 0L) {
                        for (i in 0..it.size()) {
                            kotlin.io.println(it.get(i))
                        }
                    }

                }
                geth?.getNodeInfo()?.let {
                    println("id ${it.id}")
                    println("name ${it.name}")
                    println("enode ${it.enode}")
                    println("ip ${it.ip}")
                    println("discoveryPort ${it.discoveryPort}")
                    println("listenerPort ${it.listenerPort}")
                    println("listenerAddress ${it.listenerAddress}")
                    println("protocols ${it.protocols}")
                }
                println(geth?.getPeersInfo())
                println(geth?.getNodeInfo())
                println("===")
            }
        }, 0, 1000)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        BundledAssetProviderApplication.setInstance(application)

        setContentView(R.layout.activity_main)

        val tv: TextView = findViewById(R.id.text_view)
        tv.text = secureRand(128).toString()

        val gethPath = applicationContext.getDir("geth", Context.MODE_PRIVATE).path
        geth = Node(gethPath, NodeConfig())
        geth?.start()
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
        WalletCoreTests().runAll()
        println("=== all tests executed ===")
    }
}
