// Created by web3d3v on 06/10/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

class SectionHeaderView: UICollectionReusableView {
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyTheme(Theme)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }

    private func applyTheme(_ theme: ThemeProtocol) {
        label.textColor = theme.color.textSecondary
        label.font = theme.font.sectionHeader
    }
}

extension SectionHeaderView {

    func update(with viewModel: SectionHeaderViewModel?) -> Self {
        label.text = viewModel?.title
        return self
    }

    func update(with viewModel: CollectionViewModel.Section?) -> Self {
        label.text = viewModel?.header?.uppercased()
        return self
    }
}
