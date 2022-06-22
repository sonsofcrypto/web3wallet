// Created by web3d4v on 21/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import AVFoundation

protocol QRCodeScanView: AnyObject {

    func update(with viewModel: QRCodeScanViewModel)
}

final class QRCodeScanViewController: BaseViewController {
    
    var presenter: QRCodeScanPresenter!

    private var viewModel: QRCodeScanViewModel?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter?.present()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        guard captureSession?.isRunning == false else { return }
        
        captureSession?.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        guard captureSession?.isRunning == true else { return }

        captureSession?.stopRunning()
    }
    
    @objc override func dismissTapped() {
        
        presenter.handle(.dismiss)
    }
}

extension QRCodeScanViewController: QRCodeScanView {

    func update(with viewModel: QRCodeScanViewModel) {

        self.viewModel = viewModel
        
        configureNavigationBar(title: viewModel.title)
    }
}

private extension QRCodeScanViewController {
    
    func configureUI() {
        
        (view as? GradientView)?.colors = [
            Theme.color.background,
            Theme.color.backgroundDark
        ]
        
        configureLeftBarButtonItemDismissAction()
        
        configureQRCodeScan()
    }
    
    func configureQRCodeScan() {
        
        let captureSession = AVCaptureSession()
        self.captureSession = captureSession

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            qrCodeScanUnsupported()
            return
        }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            qrCodeScanUnsupported()
            return
        }
        
        guard captureSession.canAddInput(videoInput) else {
            qrCodeScanUnsupported()
            return
        }
        captureSession.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()

        guard captureSession.canAddOutput(metadataOutput) else {
            
            qrCodeScanUnsupported()
            return
        }
        
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(previewLayer)
        
        self.previewLayer = previewLayer

        captureSession.startRunning()
    }
    
    func qrCodeScanUnsupported() {
        
        let alert = UIAlertController(
            title: Localized("qrCodeScan.error.notSupported.title"),
            message: Localized("qrCodeScan.error.notSupported.message"),
            preferredStyle: .alert
        )
        alert.addAction(.init(title: Localized("OK"), style: .default))
        present(alert, animated: true)
        captureSession = nil
    }

}

extension QRCodeScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        
        guard let metadataObject = metadataObjects.first else { return }

        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
        
        guard let qrCode = readableObject.stringValue else { return }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        presenter.handle(.qrCode(qrCode))
    }

}

private extension UIImage {
    
    var qrCode: String? {
        
        guard
            let detector = CIDetector(
                ofType: CIDetectorTypeQRCode,
                context: nil,
                options: [
                    CIDetectorAccuracy: CIDetectorAccuracyHigh
                ]
            ),
            let ciImage = CIImage(image: self),
            let features = detector.features(in: ciImage) as? [CIQRCodeFeature]
        else {
            return nil
        }

        var qrCode = ""
        for feature in features {
            
            guard let indeedMessageString = feature.messageString else {
                continue
            }
            qrCode += indeedMessageString
        }

        return qrCode.isEmpty ? nil : qrCode
    }
}
