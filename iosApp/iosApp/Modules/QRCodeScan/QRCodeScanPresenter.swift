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

        updateView(with: nil)
    }

    func handle(_ event: QRCodeScanPresenterEvent) {

        switch event {
            
        case let .qrCode(qrCode):
            
            switch context.type {
                
            case .`default`:
                wireframe.navigate(to: .qrCode(qrCode))
                
            case let .network(network):
                
                guard let address = interactor.validateAddress(
                    address: qrCode,
                    for: network
                ) else {
                    
                    let failureMessage = makeFailureMessage(for: qrCode, and: network)
                    updateView(with: failureMessage)
                    return
                }
                wireframe.navigate(to: .qrCode(address))
            }
            
        case .dismiss:
            
            wireframe.dismiss()
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
    
    func makeFailureMessage(
        for qrCode: String,
        and network: Web3Network
    ) -> String {
        
        "\(qrCode)\nis not a valid \(network.name) address"
    }
}
