// Created by web3d4v on 12/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class TokenPickerGroupCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var widthLayoutConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        
        super.awakeFromNib()
                
        nameLabel.applyStyle(.body)
        nameLabel.textColor = Theme.colour.labelSecondary
    }

    func update(
        with viewModel: TokenPickerViewModel.Group,
        and width: CGFloat
    ) {

        nameLabel.text = viewModel.name
        
        widthLayoutConstraint.constant = width
    }
}
