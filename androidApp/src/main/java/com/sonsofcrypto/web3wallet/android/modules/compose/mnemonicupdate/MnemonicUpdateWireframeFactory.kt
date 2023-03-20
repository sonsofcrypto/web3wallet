package com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicupdate

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdateWireframe
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdateWireframeContext
import smartadapter.internal.extension.name

interface MnemonicUpdateWireframeFactory {
    fun make(parent: Fragment?, context: MnemonicUpdateWireframeContext): MnemonicUpdateWireframe
}

class DefaultMnemonicUpdateWireframeFactory(
    private val keyStoreService: KeyStoreService,
): MnemonicUpdateWireframeFactory {

    override fun make(
        parent: Fragment?, context: MnemonicUpdateWireframeContext
    ): MnemonicUpdateWireframe = DefaultMnemonicUpdateWireframe(
        parent?.let { WeakRef(it) },
        context,
        keyStoreService,
    )
}

class MnemonicUpdateWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(MnemonicUpdateWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultMnemonicUpdateWireframeFactory(
                it.resolve(KeyStoreService::class.name),
            )
        }
    }
}