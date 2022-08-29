// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class KeyStoreCell: CollectionViewCell {
    
    @IBOutlet weak var indexImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var arrowForward: UIImageView!
    
    private var accessoryHandler: (() -> Void)? = nil
        
    override func awakeFromNib() {
        super.awakeFromNib()
                
        titleLabel.apply(style: .title3)
        
        subtitleLabel.apply(style: .footnote)
        subtitleLabel.textColor = Theme.colour.labelSecondary

        accessoryButton.addTarget(
            self,
            action: #selector(accessoryAction(_:)),
            for: .touchUpInside
        )
        arrowForward.image = "chevron.right".assetImage
        accessoryButton.tintColor = Theme.colour.labelPrimary
        arrowForward.tintColor = Theme.colour.labelPrimary
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setSelected(isSelected)
    }
}

extension KeyStoreCell {
    
    func update(
        with viewModel: KeyStoreViewModel.KeyStoreItem?,
        accessoryHandler: (()->())? = nil,
        index: Int
    ) -> Self {

        self.accessoryHandler = accessoryHandler
        
        let image = "\(index + 1).square.fill".assetImage!
        let config = UIImage.SymbolConfiguration(
            paletteColors: [
                Theme.colour.keystoreEnumText,
                Theme.colour.keystoreEnumFill
            ]
        )

        indexImage.image = image.applyingSymbolConfiguration(config)
        titleLabel.text = viewModel?.title
        subtitleLabel.text = viewModel?.address
        subtitleLabel.isHidden = viewModel?.address?.isEmpty ?? true
        return self
    }
}

private extension KeyStoreCell {
    
    @objc func accessoryAction(_ sender: UIButton) {
        accessoryHandler?()
    }
}
