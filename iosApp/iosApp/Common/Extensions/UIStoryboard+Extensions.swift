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
        case alert = "Alert"
        case degen = "Degen"
        case cultProposals = "CultProposals"
        case keyStore = "KeyStore"
        case mnemonicNew = "MnemonicNew"
        case mnemonicUpdate = "MnemonicUpdate"
        case mnemonicImport = "MnemonicImport"
        case dashboard = "Dashboard"
        case networks = "Networks"
        case account = "Account"
        case mnemonicConfirmation = "MnemonicConfirmation"
        case apps = "Apps"
        case chat = "Chat"
        case tokenPicker = "TokenPicker"
        case tokenReceive = "TokenReceive"
        case tokenAdd = "TokenAdd"
        case tokenSend = "TokenSend"
        case tokenSwap = "TokenSwap"
        case networkPicker = "NetworkPicker"
        case qrCodeScan = "QRCodeScan"
        case authenticate = "Authenticate"
        case confirmation = "Confirmation"
    }
}
