// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DashboardHeaderBalanceView: UICollectionReusableView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet var labelHConstraints: [NSLayoutConstraint]!
    @IBOutlet var labelVConstraints: [NSLayoutConstraint]!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        labelHConstraints.forEach { $0.constant = Theme.constant.padding }
        labelVConstraints.forEach { $0.constant = Theme.constant.padding * 1.25 }
    }
}

// MARK: - ViewModel

extension DashboardHeaderBalanceView {

    @discardableResult
    func update(with viewModel: DashboardViewModel.SectionHeaderBalance?) -> Self {
        guard let viewModel = viewModel else { return self }
        label.attributedText = .init(
            viewModel.title,
            font: Theme.font.largeTitleBold,
            fontSmall: Theme.font.title3Bold
        )
        return self
    }
}
