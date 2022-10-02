package com.sonsofcrypto.web3walletcore.root

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.utils.bip39.Bip39

interface RootPresenter {
    fun present()
}

final class DefaultRootPresenter(
//    private var rootView: Weak
    private val wireframe: RootWireframe,
    private val keyStoreService: KeyStoreService,
) : RootPresenter {

    override fun present() {
        wireframe.navigate(
            if(keyStoreService.items().isEmpty()) RootWireframeDestination.KEYSTORE
            else RootWireframeDestination.DASHBOARD
        )
    }
}
