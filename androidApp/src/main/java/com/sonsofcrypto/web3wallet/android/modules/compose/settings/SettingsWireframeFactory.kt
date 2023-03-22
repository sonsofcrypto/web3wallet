package com.sonsofcrypto.web3wallet.android.modules.compose.settings

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsWireframe
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsWireframeContext
import com.sonsofcrypto.web3walletcore.services.settings.SettingsService
import com.sonsofcrypto.web3walletcore.services.settings.SettingsServiceActionTrigger
import smartadapter.internal.extension.name

interface SettingsWireframeFactory {
    fun make(parent: Fragment?, context: SettingsWireframeContext): SettingsWireframe
}

class DefaultSettingsWireframeFactory(
    private val settingsService: SettingsService,
    private val settingsServiceActionTrigger: SettingsServiceActionTrigger,
): SettingsWireframeFactory {

    override fun make(parent: Fragment?, context: SettingsWireframeContext): SettingsWireframe {
        return DefaultSettingsWireframe(
            parent?.let { WeakRef(it) },
            context,
            settingsService,
            settingsServiceActionTrigger,
        )
    }
}

class SettingsWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(SettingsWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultSettingsWireframeFactory(
                it.resolve(SettingsService::class.name),
                it.resolve(SettingsServiceActionTrigger::class.name),
            )
        }
    }
}