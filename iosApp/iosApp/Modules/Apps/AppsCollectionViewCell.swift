// Created by web3d4v on 02/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class AppsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        //layer.applyRectShadow()
        layer.borderColor = Theme.color.tintLight.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = Global.cornerRadius

        titleLabel.textColor = Theme.color.text
        titleLabel.font = Theme.font.callout
        titleLabel.layer.shadowColor = Theme.color.tintSecondary.cgColor
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius = Global.shadowRadius
        titleLabel.layer.shadowOpacity = 1
    }

    func update(with viewModel: AppsViewModel.Item?) {
        
        titleLabel.text = viewModel?.title
    }
}
