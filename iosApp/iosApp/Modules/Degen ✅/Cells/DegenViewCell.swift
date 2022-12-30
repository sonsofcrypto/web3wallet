// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DegenViewCell: CollectionViewCell {
    @IBOutlet weak var iconImageViewWrapper: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var chevronImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        iconImageViewWrapper.backgroundColor = Theme.color.navBarTint
        iconImageViewWrapper.layer.cornerRadius = iconImageViewWrapper.frame.size.width.half
        iconImageViewWrapper.clipsToBounds = true
        iconImageView.backgroundColor = .clear
        titleLabel.apply(style: .body, weight: .bold)
        subTitleLabel.apply(style: .subheadline)
        subTitleLabel.textColor = Theme.color.textSecondary
        chevronImage.tintColor = Theme.color.textSecondary
    }
    
    override func setSelected(_ selected: Bool) {}
}

extension DegenViewCell {

    func update(
        with viewModel: DegenViewModel.Item,
        showSeparator: Bool = true
    ) {
        iconImageView.image = image(from: viewModel.iconName)
        titleLabel.text = viewModel.title
        titleLabel.textColor = viewModel.isEnabled ?
        Theme.color.textPrimary :
        Theme.color.textSecondary
        subTitleLabel.text = viewModel.subtitle
        bottomSeparatorView.isHidden = !showSeparator
    }
}

private extension DegenViewCell {
    
    func image(from imageName: String) -> UIImage? {
        if let image = UIImage(named: imageName) { return image }
        let config = UIImage.SymbolConfiguration(
            paletteColors: [
                Theme.color.textPrimary,
                .clear
            ]
        )
        return UIImage(systemName: imageName)?.applyingSymbolConfiguration(config)
    }
}
