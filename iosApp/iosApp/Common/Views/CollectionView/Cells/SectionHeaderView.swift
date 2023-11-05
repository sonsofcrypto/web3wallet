// Created by web3d3v on 06/10/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

class ThemeReusableView: UICollectionReusableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        applyTheme(Theme)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme(Theme)
    }

    func applyTheme(_ theme: ThemeProtocol) {
        // NOTE: To be overridden by subclasses to that this boiler plate does
        // not need to be in each cell
    }
}

class SectionHeaderView: ThemeReusableView {
    @IBOutlet weak var label: UILabel!

    override func applyTheme(_ theme: ThemeProtocol) {
        label.textColor = theme.color.textSecondary
        label.font = theme.font.sectionHeader
    }
}

extension SectionHeaderView {

    func update(with viewModel: String?) -> Self {
        label.text = viewModel?.uppercased()
        return self
    }

    func update(with viewModel: CollectionViewModel.Section?) -> Self {
        label.text = viewModel?.header?.uppercased()
        return self
    }
}
