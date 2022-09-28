// Created by web3d4v on 01/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class SettingsSectionFooterViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        label.apply(style: .subheadline)
        label.textColor = Theme.colour.labelSecondary
    }
}

extension SettingsSectionFooterViewCell {

    func update(with viewModel: SettingsViewModel.Section.Footer) {
        
        label.text = viewModel.body
        
        switch viewModel.textAlignment {
            
        case .leading:
            label.textAlignment = .left
        case .center:
            label.textAlignment = .center
        }
    }
}
