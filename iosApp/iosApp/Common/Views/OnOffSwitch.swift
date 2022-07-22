// Created by web3d3v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class OnOffSwitch: UISwitch {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureUI()
    }

    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        configureUI()
    }
    
    override var isEnabled: Bool {
        
        didSet {
            
            configureUI()
        }
    }
}

private extension OnOffSwitch {
    
    func configureUI() {
        
        layer.cornerRadius = 16
        
        if isEnabled {
            
            thumbTintColor = Theme.colour.switchThumbTintColor
            onTintColor = Theme.colour.switchOnTint
            backgroundColor = Theme.colour.switchBackgroundColor
        } else {
            
            onTintColor = Theme.colour.switchDisabledThumbTint
            backgroundColor = Theme.colour.switchDisabledBackgroundColor
        }
    }
}
