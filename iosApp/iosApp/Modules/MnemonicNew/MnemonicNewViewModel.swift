// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct MnemonicNewViewModel {
    var sectionsItems: [[Item]]
    var headers: [Header]
    var footers: [Footer]
    var cta: String
}

// MARK: - Access utilities

extension MnemonicNewViewModel {

    func item(at idxPath: IndexPath) -> MnemonicNewViewModel.Item? {
        sectionsItems[safe: idxPath.section]?[safe: idxPath.item]
    }

    func header(at idx: Int) -> MnemonicNewViewModel.Header {
        headers[idx]
    }

    func footer(at idx: Int) -> MnemonicNewViewModel.Footer {
        footers[idx]
    }
}

// MARK: - Item

extension MnemonicNewViewModel {

    enum Item {
        case mnemonic(mnemonic: Mnemonic)
        case name(name: Name)
        case `switch`(title: String, onOff: Bool)
        case switchWithTextInput(switchWithTextInput: SwitchWithTextInput)
        case segmentWithTextAndSwitchInput(viewModel: SegmentWithTextAndSwitchCellViewModel)
        
        var segmentWithTextAndSwitchInput: SegmentWithTextAndSwitchCellViewModel? {
            switch self {
            case let .segmentWithTextAndSwitchInput(viewModel):
                return viewModel
            default:
                return nil
            }
        }
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

extension MnemonicNewViewModel {

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

extension MnemonicNewViewModel {

    struct Name {
        let title: String
        let value: String
        let placeholder: String
    }
}

// MARK: - SwitchWithTextInput

extension MnemonicNewViewModel {

    struct SwitchWithTextInput {
        let title: String
        let onOff: Bool
        let text: String
        let placeholder: String
        let description: String
        let descriptionHighlightedWords: [String]
    }
}
