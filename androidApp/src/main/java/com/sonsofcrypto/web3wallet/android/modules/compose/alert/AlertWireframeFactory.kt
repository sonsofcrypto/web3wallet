package com.sonsofcrypto.web3wallet.android.modules.compose.alert

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.alert.AlertWireframe
import com.sonsofcrypto.web3walletcore.modules.alert.AlertWireframeContext
import smartadapter.internal.extension.name

interface AlertWireframeFactory {
    fun make(parent: Fragment?, context: AlertWireframeContext): AlertWireframe
}

class DefaultAlertWireframeFactory: AlertWireframeFactory {

    override fun make(parent: Fragment?, context: AlertWireframeContext): AlertWireframe {
        return DefaultAlertWireframe(
            parent?.let { WeakRef(it) },
            context
        )
    }
}

class AlertWireframeAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(AlertWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultAlertWireframeFactory()
        }
    }
}