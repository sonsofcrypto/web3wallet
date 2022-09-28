// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardHeaderBalanceView: UICollectionReusableView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet var labelHConstraints: [NSLayoutConstraint]!
    @IBOutlet var labelVConstraints: [NSLayoutConstraint]!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        label.apply(style: .largeTitle, weight: .bold)
        labelHConstraints.forEach { $0.constant = Theme.constant.padding }
        labelVConstraints.forEach { $0.constant = Theme.constant.padding * 1.25 }
    }
}

// MARK: - ViewModel

extension DashboardHeaderBalanceView {

    @discardableResult
    func update(with balance: String) -> Self {
        label.text = balance
        return self
    }
}
