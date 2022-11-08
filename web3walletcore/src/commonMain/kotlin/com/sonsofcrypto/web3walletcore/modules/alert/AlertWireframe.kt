package com.sonsofcrypto.web3walletcore.modules.alert

import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.alert.AlertWireframeContext.Action.Type.PRIMARY

sealed class AlertWireframeDestination {
    object Dismiss: AlertWireframeDestination()
}

data class AlertWireframeContext(
    val title: String?,
    val media: Media?,
    val message: String?,
    val actions: List<Action>,
    val onActionTapped: ((Int) -> Unit)?,
    val contentHeight: Double,
) {

    sealed class Media {
        data class Image(val named: String, val width: UInt, val height: UInt): Media()
        data class Gift(val named: String, val width: UInt, val height: UInt): Media()
    }

    data class Action(
        val title: String,
        val type: Type,
    ) {
        enum class Type {  PRIMARY, SECONDARY, DESTRUCTIVE }
    }

    companion object {

        fun underConstructionAlert(onActionTapped: ((Int) -> Unit)? = null): AlertWireframeContext =
            AlertWireframeContext(
                Localized("alert.underConstruction.title"),
                Media.Gift("under-construction", 240u, 285u),
                Localized("alert.underConstruction.message"),
                listOf(
                    Action(Localized("OK"), PRIMARY)
                ),
                onActionTapped,
                500.toDouble()
            )

        fun error(
            title: String = Localized("error.alert.title"),
            message: String,
            onActionTapped: ((Int) -> Unit)? = null,
            contentHeight: Double = 500.toDouble()
        ): AlertWireframeContext =
            AlertWireframeContext(
                title,
                Media.Gift("under-construction", 240u, 285u),
                message,
                listOf(
                    Action(Localized("OK"), PRIMARY)
                ),
                onActionTapped,
                contentHeight
            )
    }
}

interface AlertWireframe {
    fun present()
    fun navigate(destination: AlertWireframeDestination)
}
