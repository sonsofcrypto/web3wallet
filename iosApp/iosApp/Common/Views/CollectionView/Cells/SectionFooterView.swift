// Created by web3d3v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class SectionFooterView: ThemeReusableView {
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        layoutMargins = defaultInsets()
        applyTheme(Theme)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds.inset(by: layoutMargins)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme(Theme)
    }

    override func applyTheme(_ theme: ThemeProtocol) {
        label.font = theme.font.sectionFooter
        label.textColor = theme.color.textSecondary
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        layoutMargins = defaultInsets()
        label.numberOfLines = 0
    }

    private func defaultInsets() -> UIEdgeInsets {
        UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 16)
    }
}

extension SectionFooterView {

    func update(with viewModel: CollectionViewModel.Footer?) -> Self {
        guard let vm = viewModel as? CollectionViewModel.FooterHighlightWords else {
            return update(with: viewModel?.text() ?? "")
        }
        let attrStr = NSMutableAttributedString(
            string: viewModel?.text() ?? "",
            attributes: sectionFooter()
        )
        let hlAttrs: [NSAttributedString.Key : Any] = [
            .font: Theme.font.subheadlineBold,
            .foregroundColor: Theme.color.textPrimary,
        ]
        vm.words.forEach {
            let range = NSString(string: vm.text() ?? "").range(of: $0)
            attrStr.setAttributes(hlAttrs, range: range)
        }
        label.attributedText = attrStr
        return self
    }
    
    func update(with viewModel: CollectionViewModel.Section?) -> Self  {
        update(with: viewModel?.footer)
    }

    func update(with viewModel: String) -> Self {
        label.text = viewModel
        label.font = Theme.font.sectionFooter
        return self
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
