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
        
        titleLabel.apply(style: .callout)
        rightImageView.tintColor = Theme.colour.labelPrimary
    }
    
    override var isSelected: Bool {
        
        didSet {
            
            guard let viewModel = viewModel else { return }
            guard case SettingsViewModel.Item.selectableOption = viewModel else { return }
            
            UIView.animate(withDuration: 0.1) { [weak self] in
                guard let self = self else { return }
                self.rightImageView.alpha = self.isSelected ? 1 : 0
            }
        }
    }
}

extension SettingsCell {
    
    func update(
        with viewModel: SettingsViewModel.Item
    ) -> SettingsCell {
        
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title()
        
        switch viewModel {
        case .setting:
            rightImageView.alpha = 1
            rightImageView.image = UIImage(systemName: "chevron.right")

        case let .selectableOption(_, selected):
            rightImageView.image = UIImage(systemName: "checkmark")
            rightImageView.alpha = selected ? 1 : 0

        case .action:
            rightImageView.alpha = 0
        }

        return self
    }
}
