package com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicimport

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.mnemonicImport.MnemonicImportWireframe
import com.sonsofcrypto.web3walletcore.modules.mnemonicImport.MnemonicImportWireframeContext
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicService
import com.sonsofcrypto.web3walletcore.services.password.PasswordService
import smartadapter.internal.extension.name

interface MnemonicImportWireframeFactory {
    fun make(parent: Fragment?, context: MnemonicImportWireframeContext): MnemonicImportWireframe
}

class DefaultMnemonicImportWireframeFactory(
    private val keyStoreService: KeyStoreService,
    private val mnemonicService: MnemonicService,
    private val passwordService: PasswordService,
): MnemonicImportWireframeFactory {

    override fun make(
        parent: Fragment?, context: MnemonicImportWireframeContext
    ): MnemonicImportWireframe = DefaultMnemonicImportWireframe(
        parent?.let { WeakRef(it) },
        context,
        keyStoreService,
        mnemonicService,
        passwordService,
    )
}

class MnemonicImportWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(MnemonicImportWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultMnemonicImportWireframeFactory(
                it.resolve(KeyStoreService::class.name),
                it.resolve(MnemonicService::class.name),
                it.resolve(PasswordService::class.name),
            )
        }
    }
}