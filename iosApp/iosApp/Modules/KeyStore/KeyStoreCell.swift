// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class KeyStoreCell: CollectionViewCell {
    
    @IBOutlet weak var indexImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var arrowForward: UIImageView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        titleLabel.font = Theme.font.title3
        titleLabel.textColor = Theme.colour.labelPrimary
        accessoryButton.tintColor = Theme.colour.labelSecondary
        arrowForward.tintColor = Theme.colour.labelSecondary
    }

    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        accessoryButton.removeAllTargets()
    }
}
