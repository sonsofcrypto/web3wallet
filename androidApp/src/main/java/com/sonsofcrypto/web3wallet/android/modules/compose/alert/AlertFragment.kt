package com.sonsofcrypto.web3wallet.android.modules.compose.alert

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3wallet.android.common.extensions.dp
import com.sonsofcrypto.web3wallet.android.common.extensions.drawableId
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.modules.alert.*
import com.sonsofcrypto.web3walletcore.modules.alert.AlertWireframeContext.Action.Type.*

class AlertFragment: Fragment(), AlertView {

    lateinit var presenter: AlertPresenter
    private val liveData = MutableLiveData<AlertViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { AlertScreen(it) }
            }
        }
    }

    override fun update(viewModel: AlertViewModel) {
        liveData.value = viewModel
    }

    @Composable
    private fun AlertScreen(viewModel: AlertViewModel) {
        W3WDialog(
            title = viewModel.context.title,
            media = viewModel.context.media?.let { { MediaItem(media = it) } },
            message = viewModel.context.message,
            actions = { Actions(viewModel.context) },
            onDismissRequest = { presenter.handle(AlertPresenterEvent.Dismiss) }
        )
    }

    @Composable
    private fun MediaItem(media: AlertWireframeContext.Media) {
        when (media) {
            is AlertWireframeContext.Media.Image -> {
                W3WIcon(
                    id = activity.drawableId(media.named),
                    size = media.height.dp
                )
            }
            is AlertWireframeContext.Media.Gift -> {
                W3WGifImage(
                    activity?.drawableId(media.named),
                    modifier = Modifier.height(media.height.dp)
                )
            }
        }
    }

    @Composable
    private fun Actions(context: AlertWireframeContext) {
        context.actions.forEachIndexed { idx, action ->
            when (action.type) {
                PRIMARY -> {
                    W3WButtonPrimary(title = action.title) {
                        presenter.handle(AlertPresenterEvent.SelectAction(idx))
                    }
                }
                SECONDARY -> {
                    W3WButtonSecondary(title = action.title) {
                        presenter.handle(AlertPresenterEvent.SelectAction(idx))
                    }
                }
                DESTRUCTIVE -> {
                    W3WButtonPrimary(
                        title = action.title,
                        isDestructive = true,
                    ) {
                        presenter.handle(AlertPresenterEvent.SelectAction(idx))
                    }
                }
            }
            if (context.actions.last() != action) { W3WSpacerVertical() }
        }
    }
}