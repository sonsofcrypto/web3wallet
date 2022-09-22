// Created by web3d4v on 03/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class CurrencyPickerSectionCell: UICollectionReusableView {
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = Theme.font.headlineBold
        label.textColor = Theme.colour.labelPrimary
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

    func update(with viewModel: CurrencyPickerViewModel.Section) {
        label.text = viewModel.name
        switch viewModel.type {
        case .networks:
            leadingConstraint.constant = 0
            trailingConstraint.constant = 0
        case .tokens:
            leadingConstraint.constant = Theme.constant.padding
            trailingConstraint.constant = Theme.constant.padding
        }
    }
}
