// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class SettingsListSelectCell: SettingsCell {

    @IBOutlet weak var selectionImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.selectionImageView.alpha = (self?.isSelected ?? false) ? 1 : 0
            }
        }
    }
}
