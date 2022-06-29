// Created by web3d4v on 21/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

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
    private let interactor: QRCodeScanInteractor
    private let wireframe: QRCodeScanWireframe
    private let context: QRCodeScanWireframeContext
    
    init(
        view: QRCodeScanView,
        interactor: QRCodeScanInteractor,
        wireframe: QRCodeScanWireframe,
        context: QRCodeScanWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.context = context
    }
}

extension DefaultQRCodeScanPresenter: QRCodeScanPresenter {

    func present() {

        let viewModel = QRCodeScanViewModel(title: Localized("qrCodeScan.title"))
        view?.update(with: viewModel)
    }

    func handle(_ event: QRCodeScanPresenterEvent) {

        switch event {
            
        case let .qrCode(qrCode):
            
            guard interactor.isValid(address: qrCode, for: context.network) else { return }
            
            wireframe.navigate(to: .qrCode(qrCode))
            
        case .dismiss:
            
            wireframe.dismiss()
        }
    }
}
