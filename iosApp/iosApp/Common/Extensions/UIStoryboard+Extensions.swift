// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIStoryboard {

    convenience init(_ id: Id, bundle: Bundle? = nil) {
        self.init(name: id.rawValue, bundle: bundle)
    }

    func instantiate<T: UIViewController>() -> T {
        let id = "\(T.self)"
        if let vc = instantiateViewController(withIdentifier: id) as? T {
            return vc
        }
        fatalError("Failed to instantiate \(id)")
    }
}

// MARK: - Ids

extension UIStoryboard {

    enum Id: String {
        case main = "Main"
        case dashboard = "Dashboard"
        case account = "Account"
        case mnemonicConfirmation = "MnemonicConfirmation"
        case apps = "Apps"
        case chat = "Chat"
        case tokenPicker = "TokenPicker"
        case tokenReceive = "TokenReceive"
        case tokenAdd = "TokenAdd"
        case networkPicker = "NetworkPicker"
        case qrCodeScan = "QRCodeScan"
    }
}
