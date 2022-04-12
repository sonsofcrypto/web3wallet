// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct NewMnemonicViewModel {
    var sectionsItems: [[Item]]
    var headers: [Header]
    var footers: [Footer]
}

// MARK: - Access utilities

extension NewMnemonicViewModel {

    func item(at idxPath: IndexPath) -> NewMnemonicViewModel.Item? {
        sectionsItems[safe: idxPath.section]?[safe: idxPath.item]
    }

    func header(at idx: Int) -> NewMnemonicViewModel.Header {
        headers[idx]
    }

    func footer(at idx: Int) -> NewMnemonicViewModel.Footer {
        footers[idx]
    }
}

// MARK: - Item

extension NewMnemonicViewModel {

    enum Item {
        case mnemonic(mnemonic: Mnemonic)
        case name(name: Name)
    }

    enum Header {
        case none
        case header(text: AttributedString)
    }

    enum Footer {
        case none
        case attrStr(text: String, highlightWords: [String])
    }
}

// MARK: - MnemonicType

extension NewMnemonicViewModel {

    struct Mnemonic {
        let value: String
        let type: MnemonicType

        enum MnemonicType {
            case new
            case importing
            case editHidden
            case editShown
        }
    }
}

// MARK: - Name

extension NewMnemonicViewModel {

    struct Name {
        let title: String
        let value: String
        let placeHolder: String
    }
}
