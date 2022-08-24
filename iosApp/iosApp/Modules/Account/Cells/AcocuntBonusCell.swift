// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class AccountBonusCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chevronImage: UIImageView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        titleLabel.apply(style: .callout, weight: .bold)
        layer.cornerRadius = Theme.constant.cornerRadiusSmall * 2
        
        chevronImage.tintColor = Theme.colour.labelPrimary
    }
    
    override func setSelected(_ selected: Bool) {}

}
