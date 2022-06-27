// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardSectionHeaderView: UICollectionReusableView {

    private lazy var label: UILabel = {
        
        let label = UILabel(with: .callout)
        self.addSubview(label)
        label.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Global.padding)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Global.padding)),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor)
            ]
        )
        return label
    }()
}

extension DashboardSectionHeaderView {

    func update(with viewModel: DashboardViewModel.Section?) {
        
        label.text = viewModel?.name
    }
}
