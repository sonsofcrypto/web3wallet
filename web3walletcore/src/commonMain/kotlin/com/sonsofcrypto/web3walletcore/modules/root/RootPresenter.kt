package com.sonsofcrypto.web3walletcore.modules.root

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.modules.root.RootWireframeDestination.KEYSTORE
import com.sonsofcrypto.web3walletcore.modules.root.RootWireframeDestination.DASHBOARD

interface RootPresenter {
    fun present()
}

final class DefaultRootPresenter(
    private var rootView: WeakRef<RootView>,
    private val wireframe: RootWireframe,
    private val keyStoreService: KeyStoreService,
) : RootPresenter {

    override fun present() {
        wireframe.navigate(
            if(keyStoreService.items().isEmpty()) KEYSTORE else DASHBOARD
        )
    }
}
