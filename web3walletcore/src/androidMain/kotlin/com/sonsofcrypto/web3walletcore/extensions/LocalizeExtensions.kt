package com.sonsofcrypto.web3walletcore.extensions

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

actual fun Localized(string: String): String {
    return App.context.getStringResourceByName(string) ?: "-"
}

actual fun Localized(fmt: String, vararg args: Any?): String {
    val context = App.context
    val resources = context.resources
    val resId = resources.getIdentifier(fmt, "string", context.packageName)
    return when (args.size) {
        0 -> fmt
        1 -> { resources.getString(resId, args[0]) }
        2 -> resources.getString(resId, args[0], args[1])
        3 -> resources.getString(resId, args[0], args[1], args[2])
        4 -> resources.getString(resId, args[0], args[1], args[2], args[3])
        5 -> resources.getString(resId, args[0], args[1], args[2], args[3], args[4])
        6 -> resources.getString(resId, args[0], args[1], args[2], args[3], args[4], args[5])
        7 -> resources.getString(resId, args[0], args[1], args[2], args[3], args[4], args[5], args[6])
        8 -> resources.getString(resId, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7])
        9 -> resources.getString(resId, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
        10 -> resources.getString(resId, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9])
        else -> throw IllegalStateException("android String.format() can only accept up to 10 arguments")
    }
}

open class App: AppCompatActivity() {

    companion object {
        lateinit var context: Context
        lateinit var activity: AppCompatActivity

        fun openUrl(url: String) {
            val intent = Intent(Intent.ACTION_VIEW)
            intent.data = Uri.parse(url)
            activity.startActivity(intent)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        context = baseContext
        activity = this
    }
}

fun Context.getStringResourceByName(stringName: String): String? {
    val resId = resources.getIdentifier(stringName, "string", packageName)
    return getString(resId)
}