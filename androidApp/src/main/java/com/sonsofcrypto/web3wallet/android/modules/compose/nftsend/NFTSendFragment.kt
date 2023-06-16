package com.sonsofcrypto.web3wallet.android.modules.compose.nftsend

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.requiredSize
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3lib.types.NetworkFee
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.common.viewModels.NetworkAddressPickerViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.NetworkFeeViewModel
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.nftSend.NFTSendPresenter
import com.sonsofcrypto.web3walletcore.modules.nftSend.NFTSendPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.nftSend.NFTSendView
import com.sonsofcrypto.web3walletcore.modules.nftSend.NFTSendViewModel
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem

class NFTSendFragment: Fragment(), NFTSendView {

    lateinit var presenter: NFTSendPresenter
    private var liveData = MutableLiveData<NFTSendViewModel>()
    private val networkFeesData = MutableLiveData<DialogNetworkFee>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                val dialogNetworkFees by networkFeesData.observeAsState()
                viewModel?.let { NFTSendScreen(it, dialogNetworkFees) }
            }
        }
    }

    override fun update(viewModel: NFTSendViewModel) {
        liveData.value = viewModel
    }

    override fun presentNetworkFeePicker(networkFees: List<NetworkFee>, selected: NetworkFee?) {
        networkFeesData.value = DialogNetworkFee(networkFees, selected)
    }

    override fun dismissKeyboard() {}

    @Composable
    private fun NFTSendScreen(
        viewModel: NFTSendViewModel,
        dialogNetworkFees: DialogNetworkFee?,
    ) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = viewModel.title) },
            content = { NFTSendContent(viewModel, dialogNetworkFees) }
        )
    }

    @Composable
    private fun NFTSendContent(
        viewModel: NFTSendViewModel,
        dialogNetworkFees: DialogNetworkFee?,
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(theme().shapes.padding),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            var value by remember { mutableStateOf(TextFieldValue("")) }
            viewModel.nftData()?.let {
                val screenWidth = LocalConfiguration.current.screenWidthDp
                val imageSize = (screenWidth * 0.6).dp
                W3WSpacerVertical()
                W3WImage(
                    url = it.image,
                    modifier = Modifier.requiredSize(imageSize)
                )
                W3WSpacerVertical()
            }
            viewModel.addressData()?.let {
                var address by remember { mutableStateOf(TextFieldValue(it.value?: "")) }
                if (address.text != it.value) {
                    val newValue = it.value ?: ""
                    address = TextFieldValue(newValue, TextRange(newValue.length))
                }
                W3WAddressSelectorView(
                    viewModel = it,
                    value = address,
                    onClear = {
                        address = TextFieldValue("")
                        presenter.handle(NFTSendPresenterEvent.AddressChanged(address.text))
                    },
                    onValueChanged = { newAddress ->
                        address = newAddress
                        presenter.handle(NFTSendPresenterEvent.AddressChanged(address.text))
                    },
                    onQRCodeClick = { presenter.handle(NFTSendPresenterEvent.QrCodeScan) },
                )
                W3WSpacerVertical()
            }
            viewModel.networkData()?.let {
                W3WSpacerVertical()
                W3WNetworkFeeRowView(
                    viewModel = it,
                    onClick = { presenter.handle(NFTSendPresenterEvent.NetworkFeeTapped) }
                )
            }
            viewModel.buttonData()?.let {
                W3WSpacerVertical()
                SendButton(it)
            }
            if (dialogNetworkFees != null) {
                W3WDialogNetworkFeePicker(
                    onDismissRequest = { networkFeesData.value = null },
                    networkFees = dialogNetworkFees.networkFees,
                    networkFeeSelected = dialogNetworkFees.networkFee,
                    onNetworkFeeSelected = {
                        presenter.handle(NFTSendPresenterEvent.NetworkFeeChanged(it))
                    }
                )
            }
        }
    }

    @Composable
    fun SendButton(viewModel: NFTSendViewModel.ButtonState) {
        when (viewModel) {
            NFTSendViewModel.ButtonState.INVALID_DESTINATION -> {
                W3WButtonPrimary(
                    title = Localized("nftSend.missing.address"),
                    isEnabled = false,
                )
            }
            NFTSendViewModel.ButtonState.READY -> {
                W3WButtonPrimary(
                    title = Localized("send"),
                    onClick = { presenter.handle(NFTSendPresenterEvent.Review) }
                )
            }
        }
    }
}

private fun NFTSendViewModel.addressData(): NetworkAddressPickerViewModel? {
    val item = items.first {
        when (it) {
            is NFTSendViewModel.Item.Address -> true
            else -> false
        }
    }
    return (item as? NFTSendViewModel.Item.Address)?.data
}

private fun NFTSendViewModel.nftData(): NFTItem? {
    val item = items.first {
        when (it) {
            is NFTSendViewModel.Item.Nft -> true
            else -> false
        }
    }
    return (item as? NFTSendViewModel.Item.Nft)?.data
}

private fun NFTSendViewModel.networkData(): NetworkFeeViewModel? {
    val item = items.first {
        when (it) {
            is NFTSendViewModel.Item.Send -> true
            else -> false
        }
    }
    return (item as? NFTSendViewModel.Item.Send)?.networkFee
}

private fun NFTSendViewModel.buttonData(): NFTSendViewModel.ButtonState? {
    val item = items.first {
        when (it) {
            is NFTSendViewModel.Item.Send -> true
            else -> false
        }
    }
    return (item as? NFTSendViewModel.Item.Send)?.buttonState
}
