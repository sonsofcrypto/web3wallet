// Created by web3d3v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class NetworksSectionHeaderView: UICollectionReusableView {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var separatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        label.font = Theme.font.networkTitle
        label.textColor = Theme.color.textPrimary
        separatorView.backgroundColor = Theme.color.separator
    }
}
