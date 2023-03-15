package com.sonsofcrypto.web3wallet.android.modules.compose.currencyreceive

import android.graphics.Bitmap
import android.graphics.Color
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.text.style.TextAlign
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.google.zxing.BarcodeFormat
import com.google.zxing.EncodeHintType
import com.google.zxing.qrcode.QRCodeWriter
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extensions.double
import com.sonsofcrypto.web3wallet.android.common.extensions.oneAndHalf
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.app.App
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.CurrencyReceivePresenter
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.CurrencyReceiveView
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.CurrencyReceiveViewModel

class CurrencyReceiveFragment: Fragment(), CurrencyReceiveView {

    lateinit var presenter: CurrencyReceivePresenter
    private val liveData = MutableLiveData<CurrencyReceiveViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { CurrencyReceiveScreen(viewModel = it) }
            }
        }
    }

    override fun update(viewModel: CurrencyReceiveViewModel) {
        liveData.value = viewModel
    }

    @Composable
    private fun CurrencyReceiveScreen(viewModel: CurrencyReceiveViewModel) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = viewModel.title) },
            content = { CurrencyReceiveContent(viewModel) }
        )
    }

    @Composable
    private fun CurrencyReceiveContent(viewModel: CurrencyReceiveViewModel) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(ScrollState(0))
                .padding(theme().shapes.padding),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            QRCodeView(viewModel)
            W3WSpacerVertical(theme().shapes.padding.double)
            W3WText(
                text = viewModel.disclaimer,
                modifier = Modifier
                    .padding(
                        start = theme().shapes.padding,
                        end = theme().shapes.padding
                    ),
                textAlign = TextAlign.Center,
            )
            W3WSpacerVertical(theme().shapes.padding.double)
            ActionsView(viewModel.address)
        }
    }

    @Composable
    private fun QRCodeView(viewModel: CurrencyReceiveViewModel) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(
                    top = theme().shapes.padding.oneAndHalf,
                    start = theme().shapes.padding.oneAndHalf,
                    end = theme().shapes.padding.oneAndHalf,
                )
                .then(ModifierCardBackground())
                .padding(theme().shapes.padding),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            W3WText(
                text = viewModel.name,
                textAlign = TextAlign.Center,
            )
            W3WSpacerVertical()
            W3WImage(
                bitmap = generateQRCodeBitmap(
                    address = viewModel.address,
                    size = 650
                ).asImageBitmap()
            )
            W3WSpacerVertical()
            W3WText(
                text = viewModel.address,
                modifier = Modifier.padding(
                    start = theme().shapes.padding.double,
                    end = theme().shapes.padding.double
                ),
                textAlign = TextAlign.Center,
            )
        }
    }

    @Composable
    private fun ActionsView(address: String) {
        Row {
            W3WButtonSquare(
                iconId = R.drawable.icon_copy_24,
                title = Localized("currencyReceive.action.copy")
            ) {
                App.copyToClipboard(address)
                Toast.makeText(
                    context, Localized("currencyReceive.action.copy.toast"), Toast.LENGTH_LONG
                ).show()
            }
            W3WSpacerHorizontal(theme().shapes.padding * 2)
            W3WButtonSquare(
                iconId = R.drawable.icon_ios_share_24,
                title = Localized("currencyReceive.action.share")
            ) {
                App.share(address)
            }
        }
    }

    private fun generateQRCodeBitmap(address: String, size: Int = 512): Bitmap {
        hashMapOf<EncodeHintType, Int>().also { it[EncodeHintType.MARGIN] = 1 } // Make the QR code buffer border narrower
        val bits = QRCodeWriter().encode(address, BarcodeFormat.QR_CODE, size, size)
        return Bitmap.createBitmap(size, size, Bitmap.Config.RGB_565).also {
            for (x in 0 until size) {
                for (y in 0 until size) {
                    it.setPixel(x, y, if (bits[x, y]) Color.BLACK else Color.WHITE)
                }
            }
        }
    }
}