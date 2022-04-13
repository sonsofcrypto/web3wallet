// Created by web3d3v on 13/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct ButtonSheetViewModel: Equatable {
    let buttons: [Button]
    let isExpanded: Bool
}

// MARK: - ButtonType

extension ButtonSheetViewModel {

    enum ButtonType: Equatable {
        case newMnemonic
        case importMnemonic
        case moreOption
        case connectHardwareWallet
        case importPrivateKey
        case createMultiSig
    }
}

// MARK: - Button

extension ButtonSheetViewModel {

    struct Button: Equatable {
        let title: String
        let type: ButtonType
    }
}

// MARK: - Button

extension ButtonSheetViewModel {

    static func compactButtons() -> [ButtonSheetViewModel.Button] {
        [
            Button(title: Localized("keyStore.newMnemonic"), type: .newMnemonic),
            Button(title: Localized("keyStore.importMnemonic"), type: .importMnemonic),
            Button(title: Localized("keyStore.moreOption"), type: .moreOption),
            Button(title: Localized("keyStore.importPrivateKey"), type: .importPrivateKey),
            Button(title: Localized("keyStore.createMultiSig"), type: .createMultiSig)
        ]
    }

    static func expandedButtons() -> [ButtonSheetViewModel.Button] {
        [
            Button(title: Localized("keyStore.newMnemonic"), type: .newMnemonic),
            Button(title: Localized("keyStore.importMnemonic"), type: .importMnemonic),
            Button(title: Localized("keyStore.connectHardwareWallet"), type: .connectHardwareWallet),
            Button(title: Localized("keyStore.importPrivateKey"), type: .importPrivateKey),
            Button(title: Localized("keyStore.createMultiSig"), type: .createMultiSig)
        ]
    }
}
