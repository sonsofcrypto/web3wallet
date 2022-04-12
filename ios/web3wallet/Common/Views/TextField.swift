// Created by web3d3v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class TextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    func configure() {
        defaultTextAttributes = Theme.current.bodyTextAttributes()
        typingAttributes = Theme.current.bodyTextAttributes()
        backgroundColor = Theme.current.backgroundDark.withAlphaComponent(0.25)
        clipsToBounds = true
        layer.applyBorder(Theme.current.tintPrimaryLight)
        layer.cornerRadius = Global.cornerRadius
    }
}
