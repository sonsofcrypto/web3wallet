package com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicnew

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.mnemonicNew.MnemonicNewWireframe
import com.sonsofcrypto.web3walletcore.modules.mnemonicNew.MnemonicNewWireframeContext
import com.sonsofcrypto.web3walletcore.services.password.PasswordService
import smartadapter.internal.extension.name

interface MnemonicNewWireframeFactory {
    fun make(parent: Fragment?, context: MnemonicNewWireframeContext): MnemonicNewWireframe
}

class DefaultMnemonicNewWireframeFactory(
    private val keyStoreService: KeyStoreService,
    private val passwordService: PasswordService,
): MnemonicNewWireframeFactory {

    override fun make(
        parent: Fragment?, context: MnemonicNewWireframeContext
    ): MnemonicNewWireframe = DefaultMnemonicNewWireframe(
        parent?.let { WeakRef(it) },
        context,
        keyStoreService,
        passwordService,
    )
}

class MnemonicNewWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(MnemonicNewWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultMnemonicNewWireframeFactory(
                it.resolve(KeyStoreService::class.name),
                it.resolve(PasswordService::class.name),
            )
        }
    }
}