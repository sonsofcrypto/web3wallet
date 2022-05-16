// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class DashboardSectionHeaderView: UICollectionReusableView {

    private lazy var label: UILabel = {
        let label = UILabel(with: .callout)
        self.addSubview(label)
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        label.sizeToFit()
        label.frame.origin.x = Global.padding
        label.frame.origin.y = bounds.height - Global.padding - label.bounds.height
    }
}

// MARK: - DashboardViewModel

extension DashboardSectionHeaderView {

    func update(with viewModel: DashboardViewModel.Section?) {
        label.text = viewModel?.name
    }
}