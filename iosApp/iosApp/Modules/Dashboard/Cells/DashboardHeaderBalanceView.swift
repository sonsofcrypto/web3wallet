// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardHeaderBalanceView: UICollectionReusableView, ThemeProviding {
    
    private lazy var label: UILabel = {
        
        let label = UILabel()
        label.font = theme.font(for: .largeTitle)
        label.textAlignment = .center
        self.addSubview(label)
        label.addConstraints(
            [
                .layout(
                    anchor: .leadingAnchor,
                    constant: .equalTo(constant: theme.padding)
                ),
                .layout(
                    anchor: .trailingAnchor,
                    constant: .equalTo(constant: theme.padding)
                ),
                .layout(anchor: .topAnchor, constant: .equalTo(constant: theme.padding * 2)),
                .layout(anchor: .bottomAnchor, constant: .equalTo(constant: theme.padding * 1.5))
            ]
        )
        return label
    }()
}

extension DashboardHeaderBalanceView {

    func update(with viewModel: DashboardViewModel.Section) {
        
        label.text = viewModel.name
    }
}
