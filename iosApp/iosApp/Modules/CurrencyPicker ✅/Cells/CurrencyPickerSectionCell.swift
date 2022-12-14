// Created by web3d4v on 03/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class CurrencyPickerSectionCell: UICollectionReusableView {
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = Theme.font.headlineBold
        label.textColor = Theme.color.textPrimary
        label.textAlignment = .left
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        leadingConstraint = label.leadingAnchor.constraint(equalTo: leadingAnchor)
        leadingConstraint.isActive = true
        trailingConstraint = label.trailingAnchor.constraint(equalTo: trailingAnchor)
        trailingConstraint.isActive = true
        bottomAnchor.constraint(
            equalTo: label.bottomAnchor,
            constant: Theme.constant.padding.half
        ).isActive = true
        return label
    }()
}

extension CurrencyPickerSectionCell {

    func update(with section: CurrencyPickerViewModel.Section) {
        label.text = section.name
        if (section as? CurrencyPickerViewModel.SectionNetworks) != nil {
            leadingConstraint.constant = 0
            trailingConstraint.constant = 0
        } else {
            leadingConstraint.constant = Theme.constant.padding
            trailingConstraint.constant = Theme.constant.padding
        }
    }
}
