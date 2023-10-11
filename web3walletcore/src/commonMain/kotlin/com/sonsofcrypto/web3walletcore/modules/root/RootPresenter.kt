package com.sonsofcrypto.web3walletcore.modules.root

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.modules.root.RootWireframeDestination.DASHBOARD
import com.sonsofcrypto.web3walletcore.modules.root.RootWireframeDestination.KEYSTORE

interface RootPresenter {
    fun present()
}

final class DefaultRootPresenter(
    private var rootView: WeakRef<RootView>,
    private val wireframe: RootWireframe,
    private val signerStoreService: SignerStoreService,
) : RootPresenter {

    override fun present() {
        wireframe.navigate(
            if(signerStoreService.items().isEmpty()) KEYSTORE else DASHBOARD
        )
    }
}
