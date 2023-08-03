package com.sonsofcrypto.web3wallet.android.modules.compose.qrcodescan

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.util.Size
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.camera.core.CameraSelector
import androidx.camera.core.CameraSelector.LENS_FACING_BACK
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.MutableLiveData
import com.google.accompanist.permissions.ExperimentalPermissionsApi
import com.google.accompanist.permissions.isGranted
import com.google.accompanist.permissions.rememberMultiplePermissionsState
import com.google.accompanist.permissions.shouldShowRationale
import com.sonsofcrypto.web3wallet.android.appContext
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.mnemonicNew.MnemonicNewPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.qrCodeScan.QRCodeScanPresenter
import com.sonsofcrypto.web3walletcore.modules.qrCodeScan.QRCodeScanPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.qrCodeScan.QRCodeScanPresenterEvent.Dismiss
import com.sonsofcrypto.web3walletcore.modules.qrCodeScan.QRCodeScanView
import com.sonsofcrypto.web3walletcore.modules.qrCodeScan.QRCodeScanViewModel

class QRCodeScanFragment : Fragment(), QRCodeScanView {

    lateinit var presenter: QRCodeScanPresenter
    private val liveData = MutableLiveData<QRCodeScanViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { QRCodeScanScreen(it) }
            }
        }
    }

    override fun update(viewModel: QRCodeScanViewModel) {
        liveData.value = viewModel
    }

    @Composable
    private fun QRCodeScanScreen(viewModel: QRCodeScanViewModel) {
        W3WScreen(
            navBar = {
                W3WNavigationBar(
                    title = viewModel.title,
                    trailingIcon = { W3WNavigationClose { presenter.handle(Dismiss) } }
                )
            },
            content = { QRCodeScanContent(viewModel) }
        )
    }

    @OptIn(ExperimentalPermissionsApi::class)
    @Composable
    private fun QRCodeScanContent(viewModel: QRCodeScanViewModel) {
        val permissionState = rememberMultiplePermissionsState(
            permissions = listOf(Manifest.permission.CAMERA)
        )
        val lifecycleOwner = LocalLifecycleOwner.current
        DisposableEffect(
            key1 = lifecycleOwner,
            effect = {
                val observer = LifecycleEventObserver { _, event ->
                    if (event == Lifecycle.Event.ON_RESUME) {
                        permissionState.launchMultiplePermissionRequest()
                    }
                }
                lifecycleOwner.lifecycle.addObserver(observer)
                onDispose {
                    lifecycleOwner.lifecycle.removeObserver(observer)
                }
            }
        )
        permissionState.permissions.forEach { perm ->
            when (perm.permission) {
                Manifest.permission.CAMERA -> {
                    when {
                        perm.status.isGranted -> {
                            QRCodeScanShowCameraInput()
                        }

                        perm.status.shouldShowRationale -> {
                            Column(
                                modifier = Modifier.fillMaxSize()
                            ) {
                                W3WText(text = "Show rational")
                            }
                        }

                        else -> {
                            // Here we assume the user rejected the permission
                            Column(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .padding(theme().shapes.padding),
                                verticalArrangement = Arrangement.Center
                            ) {
                                W3WText(
                                    text = "Permission (denied), it needs to be enabled on settings",
                                    textAlign = TextAlign.Center
                                )
                                W3WSpacerVertical()
                                W3WButtonPrimary(
                                    title = "Open settings",
                                    onClick = {
                                        val intent =
                                            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                                        val uri =
                                            Uri.fromParts("package", appContext.packageName, null)
                                        intent.data = uri
                                        appContext.startActivity(intent)
//                                        ContextCompat.startActivity(appContext, intent, null)
                                    }
                                )
                            }
                        }
                    }
                }
            }
        }
        viewModel.failure?.let {
            Toast.makeText(context, it, Toast.LENGTH_LONG).show()
        }
    }

    @Composable
    private fun QRCodeScanShowCameraInput() {
        val context = LocalContext.current
        val lifecycleOwner = LocalLifecycleOwner.current
        val cameraProviderFuture = remember {
            ProcessCameraProvider.getInstance((context))
        }
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(theme().colors.navBarTint)
        ) {
            AndroidView(
                factory = { context ->
                    val previewView = PreviewView(context)
                    val preview = Preview.Builder().build()
                    val selector = CameraSelector
                        .Builder()
                        .requireLensFacing(LENS_FACING_BACK)
                        .build()
                    preview.setSurfaceProvider(previewView.surfaceProvider)
                    val imageAnalysis = ImageAnalysis.Builder()
                        .setTargetResolution(Size(previewView.width, previewView.height))
                        .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                        .build()
                    imageAnalysis.setAnalyzer(
                        ContextCompat.getMainExecutor(context),
                        QRCodeAnalyser {
                            presenter.handle(QRCodeScanPresenterEvent.QRCode(it))
                        }
                    )
                    try {
                        cameraProviderFuture.get().bindToLifecycle(
                            lifecycleOwner,
                            selector,
                            preview,
                            imageAnalysis,
                        )
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                    previewView
                },
                modifier = Modifier.fillMaxSize()
            )
        }
    }
}