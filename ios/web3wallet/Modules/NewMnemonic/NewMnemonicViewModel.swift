// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct NewMnemonicViewModel {
    var sectionsItems: [[Item]]
    var headers: [Header]
    var footers: [Footer]
    var cta: String
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
        case `switch`(title: String, onOff: Bool)
        case switchWithTextInput(switchWithTextInput: SwitchWithTextInput)
        case segmentWithTextAndSwitchInput(segmentWithTextAndSwitchInput: SegmentWithTextAndSwitchInput)
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

// MARK: - Mnemonic

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
        let placeholder: String
    }
}

// MARK: - SwitchWithTextInput

extension NewMnemonicViewModel {

    struct SwitchWithTextInput {
        let title: String
        let onOff: Bool
        let text: String
        let placeholder: String
        let description: String
        let descriptionHighlightedWords: [String]
    }
}

// MARK: - SwitchWithTextInput

extension NewMnemonicViewModel {

    struct SegmentWithTextAndSwitchInput {
        let title: String
        let segmentOptions: [String]
        let selectedSegment: Int
        let password: String
        let placeholder: String
        let onOffTitle: String
        let onOff: Bool
    }
}
