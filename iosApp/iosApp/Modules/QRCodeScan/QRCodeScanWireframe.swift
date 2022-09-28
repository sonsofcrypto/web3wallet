// Created by web3d4v on 21/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

// MARK: - QRCodeScanWireframeContext

struct QRCodeScanWireframeContext {
    let type: `Type`
    let onCompletion: (String) -> Void

    enum `Type` {
        case `default`
        case network(Network)
    }
}

// MARK: - QRCodeScanWireframeDestination

enum QRCodeScanWireframeDestination {
    case qrCode(String)
}

// MARK: - QRCodeScanWireframe

protocol QRCodeScanWireframe {
    func present()
    func navigate(to destination: QRCodeScanWireframeDestination)
    func dismiss()
}

// MARK: - DefaultQRCodeScanWireframe

final class DefaultQRCodeScanWireframe {
    
    private weak var parent: UIViewController?
    private let context: QRCodeScanWireframeContext
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: QRCodeScanWireframeContext
    ) {
        self.parent = parent
        self.context = context
    }
}

extension DefaultQRCodeScanWireframe: QRCodeScanWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func navigate(to destination: QRCodeScanWireframeDestination) {
        switch destination {
        case let .qrCode(qrCode):
            context.onCompletion(qrCode)
            dismiss()
        }
    }
    
    func dismiss() {
        vc?.popOrDismiss()
    }
}

private extension DefaultQRCodeScanWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultQRCodeScanInteractor()
        let vc: QRCodeScanViewController = UIStoryboard(.qrCodeScan).instantiate()
        let presenter = DefaultQRCodeScanPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.presenter = presenter
        vc.hidesBottomBarWhenPushed = true
        self.vc = vc
        return vc
    }
}
