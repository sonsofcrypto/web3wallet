// Created by web3d4v on 21/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

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
    
    func navigate(destination___ destination: QRCodeScanWireframeDestination) {
        if let qrCode = destination as? QRCodeScanWireframeDestination.QRCode {
            _ = context.handler(qrCode.value)
        }
        if (destination as? QRCodeScanWireframeDestination.Dismiss) != nil {
            vc?.popOrDismiss()
        }
    }
    
    func dismiss() { vc?.popOrDismiss() }
}

private extension DefaultQRCodeScanWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultQRCodeScanInteractor()
        let vc: QRCodeScanViewController = UIStoryboard(.qrCodeScan).instantiate()
        let presenter = DefaultQRCodeScanPresenter(
            view: WeakRef(referred: vc),
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
