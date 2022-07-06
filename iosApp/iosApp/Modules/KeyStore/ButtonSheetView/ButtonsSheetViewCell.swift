// Created by web3d3v on 13/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class ButtonsSheetViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
}

// MARK: - ButtonsSheetViewModel

extension ButtonsSheetViewCell {
    
    func update(with viewModel: ButtonSheetViewModel.Button?) -> ButtonsSheetViewCell {
        
        titleLabel.text = viewModel?.title ?? ""
        
        switch viewModel?.type {
            
        case .newMnemonic:
            applyPrimary()
        default:
            applySecondary()
        }
        
        return self
    }
}

private extension ButtonsSheetViewCell {
    
    func applyPrimary() {
        
        titleLabel.font = Theme.font.title3
        titleLabel.textColor = Theme.colour.labelPrimary
        backgroundColor = Theme.colour.buttonBackgroundPrimary
        layer.cornerRadius = Theme.constant.cornerRadiusSmall
        layer.borderWidth = 0
    }
    
    func applySecondary() {
        
        titleLabel.font = Theme.font.title3
        titleLabel.textColor = Theme.colour.labelPrimary
        backgroundColor = .clear
        layer.cornerRadius = Theme.constant.cornerRadiusSmall
        layer.borderColor = Theme.colour.labelPrimary.cgColor
        layer.borderWidth = 1
    }
}
