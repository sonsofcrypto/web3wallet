// Created by web3d4v on 01/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class SettingsSectionHeaderViewCell: UICollectionReusableView {
    
    private weak var label: UILabel!
    private var topConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SettingsSectionHeaderViewCell {
    
    func configureUI() {

        let label = UILabel()
        label.apply(style: .body, weight: .bold)
        self.label = label
        addSubview(label)
        label.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Theme.padding)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Theme.padding)),
                .layout(anchor: .bottomAnchor)
            ]
        )
        topConstraint = .init(item: self, attribute: .top, relatedBy: .equal, toItem: label, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
    }
}

extension SettingsSectionHeaderViewCell {

    func update(with viewModel: String, idx: Int) -> Self {
        label.text = viewModel
        topConstraint.constant = idx == 0 ? -12 : 0
        return self
    }
}
