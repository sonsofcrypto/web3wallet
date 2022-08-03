// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct MnemonicUpdateViewModel {
    var sectionsItems: [[Item]]
    var headers: [Header]
    var footers: [Footer]
    var cta: String
    var deleteCta: String
}

// MARK: - Access utilities

extension MnemonicUpdateViewModel {

    func item(at idxPath: IndexPath) -> MnemonicUpdateViewModel.Item? {
        sectionsItems[safe: idxPath.section]?[safe: idxPath.item]
    }

    func header(at idx: Int) -> MnemonicUpdateViewModel.Header {
        headers[idx]
    }

    func footer(at idx: Int) -> MnemonicUpdateViewModel.Footer {
        footers[idx]
    }
}

// MARK: - Item

extension MnemonicUpdateViewModel {

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

extension MnemonicUpdateViewModel {

    struct Mnemonic {
        let value: String
        let type: MnemonicType

        enum MnemonicType {
            case hidden
            case shown
        }
    }
}

// MARK: - Name

extension MnemonicUpdateViewModel {

    struct Name {
        let title: String
        let value: String
        let placeholder: String
    }
}

// MARK: - SwitchWithTextInput

extension MnemonicUpdateViewModel {

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

extension MnemonicUpdateViewModel {

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
