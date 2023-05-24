package com.sonsofcrypto.web3lib.utils

import android.app.Application

actual class BundledAssetProvider {

    actual constructor() {}

    actual fun image(id: String): ByteArray? {
        // TODO: Implement
        return null
    }

    actual fun file(name: String, ext: String): ByteArray? {
//        with(BundledAssetProviderApplication.instance()) {
//            val resourceId = resources.getIdentifier(
//                "$name.$ext".substringBefore("."), "raw", packageName
//            )
//            return resources.openRawResource(resourceId).readBytes()
//        }
        return FileManager().readSync("$name.$ext", FileManager.Location.BUNDLE)
    }
}

/** Tmp work around to be able to load resources */
class BundledAssetProviderApplication() : Application() {
    companion object{
        lateinit var appInstance: Application
        fun instance() = appInstance
        fun setInstance(app: Application) {
            appInstance = app
        }
    }
}