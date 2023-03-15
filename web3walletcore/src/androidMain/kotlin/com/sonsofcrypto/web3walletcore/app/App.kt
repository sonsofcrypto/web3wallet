package com.sonsofcrypto.web3walletcore.app

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat

open class App: AppCompatActivity() {

    companion object {
        lateinit var context: Context
        lateinit var activity: AppCompatActivity

        fun openUrl(url: String) {
            val intent = Intent(Intent.ACTION_VIEW)
            intent.data = Uri.parse(url)
            activity.startActivity(intent)
        }

        fun share(text: String) {
            val sendIntent: Intent = Intent().apply {
                action = Intent.ACTION_SEND
                putExtra(Intent.EXTRA_TEXT, text)
                type = "text/plain"
            }
            val shareIntent = Intent.createChooser(sendIntent, null)
            activity.startActivity(shareIntent)
        }

        fun copyToClipboard(text: String) {
            val clipboardManager =
                ContextCompat.getSystemService(context, ClipboardManager::class.java)
            val clipData = ClipData.newPlainText("", text)
            clipboardManager?.setPrimaryClip(clipData)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        context = baseContext
        activity = this
    }
}
