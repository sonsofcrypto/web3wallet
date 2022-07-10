// Created by web3d3v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class TextField: UITextField {

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        configure()
    }
    
    override var font: UIFont? {
        
        didSet {
            
            // Update placeholder font
            attributedPlaceholder = NSAttributedString(
                string: placeholder ?? "",
                attributes: makePlaceholderAttributes()
            )
        }
    }
    
    func update(placeholder: String?) {
        
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: makePlaceholderAttributes()
        )
    }
}

private extension TextField {
    
    func configure() {

        font = Theme.font.body
        textColor = Theme.colour.textFieldTextColour
        backgroundColor = .clear
    }
    
    func makePlaceholderAttributes() -> [NSAttributedString.Key: Any] {
        [
            .font: font ?? Theme.font.body,
            .foregroundColor: Theme.colour.textFieldPlaceholderColour
        ]
    }
}
