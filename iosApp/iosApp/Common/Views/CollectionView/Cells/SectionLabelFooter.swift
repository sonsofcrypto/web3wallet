// Created by web3d3v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class SectionLabelFooter: UICollectionReusableView {
    @IBOutlet weak var label: UILabel!
}

extension SectionLabelFooter {

    func update(with viewModel: MnemonicNewViewModel.Footer) {
        switch viewModel {
        case let .attrStr(text, highlightWords):
            updateFooter(text: text, highlightWords: highlightWords)
        default:
            ()
        }
    }

    func update(with viewModel: MnemonicUpdateViewModel.Footer) {
        switch viewModel {
        case let .attrStr(text, highlightWords):
            updateFooter(text: text, highlightWords: highlightWords)
        default:
            ()
        }
    }

    func update(with viewModel: MnemonicImportViewModel.Footer) {
        switch viewModel {
        case let .attrStr(text, highlightWords):
            updateFooter(text: text, highlightWords: highlightWords)
        default:
            ()
        }
    }
}

private extension SectionLabelFooter {

    // TODO: We should probably have style for this
    func updateFooter(text: String, highlightWords: [String]) {
        let attrs = sectionFooter()
        let hlAttrs: [NSAttributedString.Key : Any] = [
            .font: Theme.font.subheadlineBold,
            .foregroundColor: Theme.colour.labelPrimary,
        ]
        let attrStr = NSMutableAttributedString(
            string: text,
            attributes:attrs
        )
        highlightWords.forEach {
            let range = NSString(string: text).range(of: $0)
            attrStr.setAttributes(hlAttrs, range: range)
        }
        label.attributedText = attrStr
    }

    // TODO: We should probably have style for this
    func sectionFooter() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        return [
            .font: Theme.font.subheadline,
            .foregroundColor: Theme.colour.labelSecondary,
            .paragraphStyle: paragraphStyle
        ]
    }
}
