// Created by web3d4v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class SeparatorView: UIView {
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        configureUI()
    }
}

private extension SeparatorView {
    
    func configureUI() {
        
        backgroundColor = Theme.colour.separatorWithTransparency

        let separatorHeight: CGFloat = 1
        if let heightConstraint = heightConstraint {
            heightConstraint.constant = separatorHeight
        } else {
            addConstraints(
                [
                    .layout(anchor: .heightAnchor, constant: .equalTo(constant: separatorHeight))
                ]
            )
        }
    }
}
