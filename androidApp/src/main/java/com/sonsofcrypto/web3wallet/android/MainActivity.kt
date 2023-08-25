package com.sonsofcrypto.web3wallet.android

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.sonsofcrypto.web3lib.utils.FileManager
import com.sonsofcrypto.web3lib.utils.secureRand


class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_main)

        val tv: TextView = findViewById(R.id.text_view)
        tv.text = secureRand(128).toString()
        println("what in the world")
    }

    override fun onResume() {
        super.onResume()
        println("WTF")
        val fm = FileManager()

        val bytes: ByteArray = FileManager().readSync(
            "docs/bitcoin_white_paper.md",
            FileManager.Location.BUNDLE
        )

        println("[MainActivity] whitepaper lenght ${bytes.decodeToString().length}")


        val filesDir = getFilesDir()
        println("Absolute ${filesDir.absolutePath}")
        try {
            fm.writeSync("Testing".toByteArray(), "test.txt")
            val result = fm.readSync("test.txt").decodeToString()
            println("RESULT $result")
        } catch (err: Throwable) {
            println("FAILED $err")
        }


        println("=== all tests executed ===")

    }
}

