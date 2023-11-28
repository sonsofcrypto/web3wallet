// Created by web3d3v on 18/10/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class SelectionCollectionViewCell: CollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var selectionView: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
        selectionView?.isHidden = true
    }

    override func setSelected(_ selected: Bool) {
        super.setSelected(selected)
        selectionView?.isHidden = !selected
    }

    func configureUI() {
        titleLabel?.apply(style: .body)
        selectionView?.tintColor = Theme.color.textPrimary
    }
}


