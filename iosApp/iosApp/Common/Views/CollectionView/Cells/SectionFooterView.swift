// Created by web3d3v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class SectionFooterView: ThemeReusableView {
    @IBOutlet weak var label: UILabel!

    override func applyTheme(_ theme: ThemeProtocol) {
        label.font = theme.font.sectionHeader
        label.textColor = theme.color.textSecondary
    }
}

extension SectionFooterView {

    func update(with viewModel: CollectionViewModel.Footer?) -> Self {
        let attrStr = NSMutableAttributedString(
            string: viewModel?.text() ?? "",
            attributes: sectionFooter()
        )
        
        if let vm = viewModel as? CollectionViewModel.FooterHighlightWords {
            let hlAttrs: [NSAttributedString.Key : Any] = [
                .font: Theme.font.subheadlineBold,
                .foregroundColor: Theme.color.textPrimary,
            ]
            vm.words.forEach {
                let range = NSString(string: vm.text() ?? "").range(of: $0)
                attrStr.setAttributes(hlAttrs, range: range)
            }
        }
        label.attributedText = attrStr
        return self
    }
    
    func update(with viewModel: CollectionViewModel.Section?) -> Self  {
        update(with: viewModel?.footer)
    }
}

private extension SectionFooterView {

    func sectionFooter() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        return [
            .font: Theme.font.sectionFooter,
            .foregroundColor: Theme.color.textSecondary,
            .paragraphStyle: paragraphStyle
        ]
    }
}
