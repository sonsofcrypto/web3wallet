// Created by web3d4v on 02/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class AppsHeaderCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private var widthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.apply(style: .callout)
    }
    
    func update(
        with viewModel: AppsViewModel.Item?,
        width: CGFloat
    ) {
        titleLabel.text = viewModel?.title
        widthConstraint.constant = width
    }
}
