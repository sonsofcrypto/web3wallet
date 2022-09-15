// Created by web3d4v on 21/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum QRCodeScanPresenterEvent {
    case qrCode(String)
    case dismiss
}

protocol QRCodeScanPresenter {
    func present()
    func handle(_ event: QRCodeScanPresenterEvent)
}

final class DefaultQRCodeScanPresenter {

    private weak var view: QRCodeScanView?
    private let wireframe: QRCodeScanWireframe
    private let interactor: QRCodeScanInteractor
    private let context: QRCodeScanWireframeContext
    
    private var qrCodeDetected = false
    
    init(
        view: QRCodeScanView,
        wireframe: QRCodeScanWireframe,
        interactor: QRCodeScanInteractor,
        context: QRCodeScanWireframeContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
        self.context = context
    }
}

extension DefaultQRCodeScanPresenter: QRCodeScanPresenter {

    func present() {
        updateView(with: nil)
    }

    func handle(_ event: QRCodeScanPresenterEvent) {
        switch event {
        case let .qrCode(qrCode):
            handleQRCode(qrCode)
        case .dismiss:
            wireframe.dismiss()
        }
    }
}

private extension DefaultQRCodeScanPresenter {
    
    func handleQRCode(_ qrCode: String) {
        switch context.type {
        case .`default`:
            // NOTE: This guard is to prevent calling multiple times wireframe.navigate(to: .qrCode())
            // since the view keeps firing multiple times the same code being scanned
            guard !qrCodeDetected else { return }
            qrCodeDetected = true
            wireframe.navigate(to: .qrCode(qrCode))
        case let .network(network):
            guard let address = interactor.validateAddress(
                address: qrCode,
                for: network
            ) else {
                let errorMessage = Localized("qrCodeScan.error.invalid.address", arg: network.name)
                updateView(with: "\(qrCode)\n\(errorMessage)")
                return
            }
            // NOTE: This guard is to prevent calling multiple times wireframe.navigate(to: .qrCode())
            // since the view keeps firing multiple times the same code being scanned
            guard !qrCodeDetected else { return }
            qrCodeDetected = true
            wireframe.navigate(to: .qrCode(address))
        }
    }
}

private extension DefaultQRCodeScanPresenter {
    
    func updateView(with failure: String?) {
        let viewModel = QRCodeScanViewModel(
            title: Localized("qrCodeScan.title"),
            failure: failure
        )
        view?.update(with: viewModel)
    }
}
