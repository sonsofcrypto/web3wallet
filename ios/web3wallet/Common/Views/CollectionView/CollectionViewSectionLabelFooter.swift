// Created by web3d3v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CollectionViewSectionLabelFooter: UICollectionReusableView {

    @IBOutlet weak var label: UILabel!
}

extension CollectionViewSectionLabelFooter {

    func update(with viewModel: MnemonicViewModel.Footer) {
        switch viewModel {
        case let .attrStr(text, highlightWords):
            let attrs = Theme.current.sectionFooterTextAttributes()
            let hlAttrs: [NSAttributedString.Key : Any] = [
                .font: Theme.current.cellDetail,
                .foregroundColor: Theme.current.tintPrimary,
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
        default:
            ()
        }
    }
}
