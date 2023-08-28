// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class SettingsCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    
    private var viewModel: SettingsViewModel.SectionItem!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        backgroundColor = .clear
        
        titleLabel.apply(style: .callout)
        rightImageView.tintColor = Theme.color.textPrimary
    }
    
    override func setSelected(_ selected: Bool) {
        
        // do nothing
    }
    
    override var isSelected: Bool {
        
        didSet {
            
            guard
                let viewModel = viewModel,
                viewModel.isSelected != nil
            else { return }
            
            UIView.animate(withDuration: 0.1) { [weak self] in
                
                guard let self = self else { return }
                self.rightImageView.alpha = self.isSelected ? 1 : 0
            }
        }
    }
}

extension SettingsCell {
    
    func update(
        with viewModel: SettingsViewModel.SectionItem,
        showSeparator: Bool = true
    ) -> SettingsCell {
        
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title
        
        if viewModel.isAction {
            if let selected = viewModel.isSelected?.boolValue {
                rightImageView.image = "checkmark".assetImage
                rightImageView.alpha = selected ? 1 : 0
            } else {
                rightImageView.alpha = 0
            }
        } else {
            rightImageView.alpha = 1
            rightImageView.image = "chevron.right".assetImage
        }

        bottomSeparatorView.isHidden = !showSeparator

        return self
    }
}
