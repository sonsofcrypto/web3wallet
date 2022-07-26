// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DegenViewCell: CollectionViewCell {
    
    @IBOutlet weak var iconImageViewWrapper: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var chevronImage: UIImageView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        backgroundColor = .clear
        
        iconImageViewWrapper.backgroundColor = Theme.colour.navBarTint
        iconImageViewWrapper.layer.cornerRadius = iconImageViewWrapper.frame.size.width.half
        iconImageViewWrapper.clipsToBounds = true

        iconImageView.backgroundColor = .clear
        
        titleLabel.apply(style: .body, weight: .bold)
        
        subTitleLabel.apply(style: .subheadline)
        subTitleLabel.textColor = Theme.colour.labelSecondary
        
        chevronImage.tintColor = Theme.colour.labelSecondary
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
        
        bottomSeparatorView.isHidden = !showSeparator
    }
}
