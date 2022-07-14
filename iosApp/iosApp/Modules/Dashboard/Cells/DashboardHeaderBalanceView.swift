// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardHeaderBalanceView: UICollectionReusableView {
    
    private lazy var label: UILabel = {
        
        let label = UILabel()
        label.apply(style: .largeTitle, weight: .bold)
        label.textAlignment = .center
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
//                .layout(anchor: .topAnchor, constant: .equalTo(constant: Theme.constant.padding * 2)),
                .layout(anchor: .bottomAnchor, constant: .equalTo(constant: Theme.constant.padding * 1.5))
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
