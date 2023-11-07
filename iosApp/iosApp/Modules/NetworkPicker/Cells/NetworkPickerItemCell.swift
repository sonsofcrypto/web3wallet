// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class NetworkPickerItemCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var widthLayoutConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width * 0.5
        iconImageView.backgroundColor = Theme.color.textPrimary
        nameLabel.apply(style: .body)
        nameLabel.textColor = Theme.color.textPrimary
    }

    func update(
        with viewModel: NetworkPickerViewModel.Item,
        and width: CGFloat
    ) {
        if let imgName = viewModel.imageName {
            iconImageView.isHidden = false
            iconImageView.image = UIImage(named: imgName)
        } else {
            iconImageView.isHidden = true
        }
        nameLabel.text = viewModel.name
        widthLayoutConstraint.constant = width
    }
}
