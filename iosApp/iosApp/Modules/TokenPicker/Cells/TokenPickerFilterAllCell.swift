// Created by web3d4v on 14/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class TokenPickerFilterCell: UICollectionViewCell {
    
    @IBOutlet weak var boundingView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        boundingView.layer.cornerRadius = 8
        boundingView.layer.borderWidth = 1
        
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width * 0.5
        iconImageView.layer.borderWidth = 1
        iconImageView.layer.borderColor = Theme.colour.fillTertiary.cgColor
        
        nameLabel.font = Theme.font.body
        nameLabel.textColor = Theme.colour.labelPrimary
    }
    
    func update(
        with viewModel: TokenPickerViewModel.Filter
    ) {

        applySelection(to: viewModel.isSelected)
        
        switch viewModel.type {
            
        case let .all(name):
            
            nameLabel.text = name
            iconImageView.isHidden = true
            
        case let .item(icon, name):
            
            nameLabel.text = name
            iconImageView.image = icon.pngImage
            iconImageView.isHidden = false
        }
    }
}

private extension TokenPickerFilterCell {
    
    func applySelection(to isSelected: Bool) {
        
        boundingView.backgroundColor = isSelected ? Theme.colour.backgroundBasePrimary : UIColor.clear
        let selectedColor = isSelected ? Theme.colour.fillPrimary : Theme.colour.fillTertiary
        boundingView.layer.borderColor = selectedColor.cgColor
    }
}
