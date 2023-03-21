package com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicconfirmation

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation.MnemonicConfirmationWireframe
import com.sonsofcrypto.web3walletcore.services.actions.ActionsService
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicService
import smartadapter.internal.extension.name

interface MnemonicConfirmationWireframeFactory {
    fun make(parent: Fragment?): MnemonicConfirmationWireframe
}

class DefaultMnemonicConfirmationWireframeFactory(
    private val keyStoreService: KeyStoreService,
    private val actionsService: ActionsService,
    private val mnemonicService: MnemonicService,
): MnemonicConfirmationWireframeFactory {

    override fun make(
        parent: Fragment?
    ): MnemonicConfirmationWireframe = DefaultMnemonicConfirmationWireframe(
        parent?.let { WeakRef(it) },
        keyStoreService,
        actionsService,
        mnemonicService,
    )
}

class MnemonicConfirmationWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(MnemonicConfirmationWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultMnemonicConfirmationWireframeFactory(
                it.resolve(KeyStoreService::class.name),
                it.resolve(ActionsService::class.name),
                it.resolve(MnemonicService::class.name),
            )
        }
    }
}