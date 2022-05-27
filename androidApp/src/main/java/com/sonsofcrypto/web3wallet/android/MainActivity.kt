package com.sonsofcrypto.web3wallet.android

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.sonsofcrypto.web3lib_bip39.Greeting
import com.sonsofcrypto.web3lib_crypto.*
import android.widget.TextView

fun greet(): String {
    return Greeting().greeting()
}

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val tv: TextView = findViewById(R.id.text_view)
        tv.text = greet() + String(Crypto().secureRand(2)) + "wtf"
    }
}
