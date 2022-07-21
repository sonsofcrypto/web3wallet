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
        accessoryButton.tintColor = Theme.colour.labelSecondary
        arrowForward.tintColor = Theme.colour.labelSecondary
        
        accessoryButton.addTarget(
            self,
            action: #selector(accessoryAction(_:)),
            for: .touchUpInside
        )
        arrowForward.image = .init(systemName: "chevron.right")
    }
}

extension KeyStoreCell {
    
    func update(
        with viewModel: KeyStoreViewModel.KeyStoreItem?,
        accessoryHandler: (()->())? = nil,
        index: Int
    ) -> Self {


        self.accessoryHandler = accessoryHandler
        
        let image = UIImage(systemName: "\(index + 1).square.fill")!
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
}
