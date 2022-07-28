// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class KeyStoreCell: CollectionViewCell {
    
    @IBOutlet weak var indexImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var arrowForward: UIImageView!
    
    private var accessoryHandler: (() -> Void)? = nil
        
    override func awakeFromNib() {
        
        super.awakeFromNib()
                
        titleLabel.font = Theme.font.title3
        titleLabel.textColor = Theme.colour.labelPrimary
        
        accessoryButton.addTarget(
            self,
            action: #selector(accessoryAction(_:)),
            for: .touchUpInside
        )
        arrowForward.image = "chevron.right".assetImage
        
        updateStyle(with: isSelected)
    }
    
    override var isSelected: Bool {
        
        didSet {
            
            updateStyle(with: isSelected)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateStyle(with: isSelected)
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
                
        return self
    }
}

private extension KeyStoreCell {
    
    @objc func accessoryAction(_ sender: UIButton) {
        accessoryHandler?()
    }
    
    func updateStyle(with isSelected: Bool) {
        
        layer.borderWidth = isSelected ? 1.0 : 0.0
        layer.borderColor = Theme.colour.labelPrimary.cgColor
        
        indexImage.alpha = isSelected ? 1.0 : 0.5
        
        titleLabel.font = isSelected
        ? Theme.font.title3Bold
        : Theme.font.title3
        titleLabel.textColor = isSelected
        ? Theme.colour.labelPrimary
        : Theme.colour.labelSecondary
        
        accessoryButton.tintColor = isSelected
        ? Theme.colour.labelPrimary
        : Theme.colour.labelSecondary
        
        arrowForward.tintColor = isSelected
        ? Theme.colour.labelPrimary
        : Theme.colour.labelSecondary
    }
}
