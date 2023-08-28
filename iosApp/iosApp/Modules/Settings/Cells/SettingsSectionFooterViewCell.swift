// Created by web3d4v on 01/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class SettingsSectionFooterViewCell: UICollectionReusableView {
    
    private weak var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SettingsSectionFooterViewCell {
    
    func configureUI() {

        let label = UILabel()
        label.apply(style: .subheadline)
        label.textColor = Theme.color.textSecondary
        self.label = label
        addSubview(label)
        label.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Theme.padding)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Theme.padding)),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor)
            ]
        )
    }
}

extension SettingsSectionFooterViewCell {

    func update(with viewModel: SettingsViewModel.SectionFooter) -> Self {
        label.text = viewModel.title
        switch viewModel.alignment {
        case .left: label.textAlignment = .left
        case .center: label.textAlignment = .center
        default: label.textAlignment = .left
        }
        return self
    }
}
