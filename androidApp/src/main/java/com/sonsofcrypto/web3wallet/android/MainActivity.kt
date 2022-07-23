package com.sonsofcrypto.web3wallet.android

import android.content.SharedPreferences
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.sonsofcrypto.web3lib_utils.*
import com.sonsofcrypto.web3lib_core.*
import android.widget.TextView
import com.sonsofcrypto.keyvaluestore.KeyValueStore


class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val tv: TextView = findViewById(R.id.text_view)
        tv.text = secureRand(128).toString()
    }

    override fun onResume() {
        super.onResume()
//        Bip39Test().runAll()
//        Bip44Test().runAll()
//        KeyValueStoreTest().runAll()
//        KeyStoreTest().runAll()
//        TrieTest().runAll()
        ProviderTest().runAll()
        println("=== all tests executed ===")
    }
}
