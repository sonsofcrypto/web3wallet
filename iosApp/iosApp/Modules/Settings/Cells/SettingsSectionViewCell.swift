// Created by web3d4v on 01/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class SettingsSectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        label.apply(style: .body, weight: .bold)
    }
}

extension SettingsSectionViewCell {

    func update(with viewModel: SettingsViewModel.Section.Header) {
        
        label.text = viewModel.title
    }
}
