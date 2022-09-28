// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class SettingsCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    
    private var viewModel: SettingsViewModel.Item!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        backgroundColor = .clear
        
        titleLabel.apply(style: .callout)
        rightImageView.tintColor = Theme.colour.labelPrimary
    }
    
    override func setSelected(_ selected: Bool) {
        
        // do nothing
    }
    
    override var isSelected: Bool {
        
        didSet {
            
            guard
                let viewModel = viewModel,
                case let Setting.`Type`.action(_, _, canSelect) = viewModel.setting.type,
                canSelect
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
        with viewModel: SettingsViewModel.Item,
        showSeparator: Bool = true
    ) -> SettingsCell {
        
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title
        
        switch viewModel.setting.type {
            
        case .item:
            rightImageView.alpha = 1
            rightImageView.image = "chevron.right".assetImage

        case let .action(_, _, showTickOnSelected):
            
            if showTickOnSelected {
                rightImageView.image = "checkmark".assetImage
                rightImageView.alpha = (viewModel.isSelected ?? false) ? 1 : 0
            } else {
                rightImageView.alpha = 0
            }
        }
        
        bottomSeparatorView.isHidden = !showSeparator

        return self
    }
}
