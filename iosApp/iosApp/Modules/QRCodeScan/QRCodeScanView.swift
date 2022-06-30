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
    private var activityIndicatorView: UIView!
    
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
}

extension QRCodeScanViewController: QRCodeScanView {

    func update(with viewModel: QRCodeScanViewModel) {

        self.viewModel = viewModel
        
        title = viewModel.title.uppercased()
    }
}

private extension QRCodeScanViewController {
    
    func configureUI() {
                
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: Localized("close"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Localized("paste"),
            style: .plain,
            target: self,
            action: #selector(pasteTapped)
        )
        
        configureQRCodeScan()
        
        addTopView()
        addActivityIndicatorView()
    }
    
    @objc func closeTapped() {
        
        presenter.handle(.dismiss)
    }
    
    @objc func pasteTapped() {
        
        let picker = UIImagePickerController()
        //picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
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

    func addTopView() {
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        
        addMask(to: blurEffectView)
        
        self.view.addSubview(blurEffectView)

        blurEffectView.addConstraints(.toEdges)
    }
    
    func addMask(to view: UIView) {
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        let size: CGFloat = self.view.bounds.width * 0.8
        let rect = CGRect(
            x: self.view.bounds.width * 0.5 - size * 0.5,
            y: self.view.bounds.height * 0.475 - size * 0.5,
            width: size,
            height: size
        )
        let circlePath = UIBezierPath(roundedRect: rect, cornerRadius: 40)
        let path = UIBezierPath(rect: self.view.bounds)
        path.append(circlePath)
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
    }
    
    func addActivityIndicatorView() {
        
        let view = UIView()
        view.backgroundColor = Theme.colour.backgroundBaseSecondary
        view.layer.cornerRadius = 24
        view.layer.borderColor = Theme.colour.fillTertiary.cgColor
        view.layer.borderWidth = 1
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        activityIndicator.color = Theme.colour.fillPrimary
        view.addSubview(activityIndicator)
        activityIndicator.addConstraints(
            [
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .centerYAnchor)
            ]
        )
        
        self.view.addSubview(view)
        
        view.addConstraints(
            [
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .centerYAnchor),
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: self.view.bounds.width * 0.25)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: self.view.bounds.width * 0.25))
            ]
        )
        
        self.activityIndicatorView = view
        view.isHidden = true
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

extension QRCodeScanViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        
        activityIndicatorView.isHidden = false
        
        picker.dismiss(animated: true) { [weak self] in
            
            guard let self = self else { return }
            
            if let qrCode = (info[.originalImage] as? UIImage)?.qrCode {
            
                self.presenter.handle(.qrCode(qrCode))
            } else {
                
                self.activityIndicatorView.isHidden = true
            }
        }
    }
}
