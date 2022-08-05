// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardHeaderBalanceView: UICollectionReusableView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet var labelConstraints: [NSLayoutConstraint]!
    @IBOutlet var leadingLineConstraints: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.apply(style: .largeTitle, weight: .bold)
        labelConstraints.forEach { $0.constant = Theme.constant.padding }
        leadingLineConstraints.constant = Theme.constant.padding / 2
    }
}

// MARK: - ViewModel

extension DashboardHeaderBalanceView {

    func update(with balance: String) {
        label.text = balance
    }
}
