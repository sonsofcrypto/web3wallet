// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DegenViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageViewWrapper: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var chevronImage: UIImageView!
    @IBOutlet weak var separatorLine: UIView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        iconImageViewWrapper.backgroundColor = Theme.colour.navBarTint
        iconImageViewWrapper.layer.cornerRadius = iconImageViewWrapper.frame.size.width.half
        iconImageViewWrapper.clipsToBounds = true

        iconImageView.backgroundColor = .clear
        
        titleLabel.apply(style: .body, weight: .bold)
        
        subTitleLabel.apply(style: .subheadline, weight: .bold)
        subTitleLabel.textColor = Theme.colour.labelSecondary
        
        chevronImage.tintColor = Theme.colour.labelSecondary
        
        separatorLine.backgroundColor = Theme.colour.separatorNoTransparency
    }
}

extension DegenViewCell {

    func update(
        with viewModel: DegenViewModel.Item,
        showSeparator: Bool = true
    ) {
        
        iconImageView.image = viewModel.icon.pngImage
        
        titleLabel.text = viewModel.title
        titleLabel.textColor = viewModel.isEnabled ?
        Theme.colour.labelPrimary :
        Theme.colour.labelSecondary
        
        subTitleLabel.text = viewModel.subtitle
        
        separatorLine.isHidden = !showSeparator
    }
}
