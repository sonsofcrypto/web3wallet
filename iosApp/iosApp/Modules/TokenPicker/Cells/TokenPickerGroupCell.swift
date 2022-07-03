// Created by web3d4v on 03/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class TokenPickerGroupCell: UICollectionReusableView {
    
    private lazy var label: UILabel = {
        
        let label = UILabel()
        label.font = Theme.font.headlineBold
        label.textColor = Theme.colour.labelPrimary
        label.textAlignment = .left
        self.addSubview(label)
        label.addConstraints(
            [
                .layout(
                    anchor: .leadingAnchor,
                    constant: .equalTo(constant: Theme.constant.padding)
                ),
                .layout(
                    anchor: .trailingAnchor,
                    constant: .equalTo(constant: Theme.constant.padding)
                ),
                .layout(anchor: .topAnchor, constant: .equalTo(constant: 28)),
                .layout(anchor: .bottomAnchor, constant: .equalTo(constant: 4))
            ]
        )
        return label
    }()
}

extension TokenPickerGroupCell {

    func update(with viewModel: TokenPickerViewModel.Section) {
        
        label.text = viewModel.name
    }
}
