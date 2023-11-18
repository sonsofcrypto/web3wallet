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
    @IBOutlet weak var trailingLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        trailingLabel?.text = nil
    }

    override func applyTheme(_ theme: ThemeProtocol) {
        [label, trailingLabel].forEach {
            $0?.textColor = theme.color.textSecondary
            $0?.font = theme.font.sectionHeader
        }
    }
}

extension SectionHeaderView {

    func update(with viewModel: String?) -> Self {
        label.text = viewModel?.uppercased()
        return self
    }

    func update(with viewModel: CollectionViewModel.Section?) -> Self {
        if let vm = viewModel?.header as? CollectionViewModel.HeaderTitle {
            label.text = vm.leading?.uppercased()
            trailingLabel?.text = vm.trailing?.uppercased()
        }
        return self
    }
}
