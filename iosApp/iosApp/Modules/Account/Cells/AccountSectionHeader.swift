// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class AccountSectionHeader: UICollectionReusableView {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.applyStyle(.subhead)
        [label, self].forEach {
            $0.clipsToBounds = false
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.layer.transform = CATransform3DMakeTranslation(0, -bounds.height * 0.2, 0)
    }
}
