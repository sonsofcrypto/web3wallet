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
    
    var placeholderAttrText: String? {
        get { attributedPlaceholder?.string }
        set {
            attributedPlaceholder = NSAttributedString(
                string: newValue ?? "",
                attributes: placeholderAttrs()
            )
        }
    }

    @objc func clearTapped() {
        text = nil
    }
}

private extension TextField {
    
    func configure() {
        font = Theme.font.body
        textColor = Theme.color.textPrimary
        rightView = makeClearButton()
        rightViewMode = .whileEditing
        clipsToBounds = true
    }
    
    func placeholderAttrs() -> [NSAttributedString.Key: Any] {
        return [
            .font: font ?? Theme.font.body,
            .foregroundColor: Theme.color.textSecondary
        ]
    }
    
    func bodyAttrs() -> [NSAttributedString.Key: Any] {
        return [
            .font: font ?? Theme.font.body,
            .foregroundColor: Theme.color.textPrimary,
        ]
    }

    func makeClearButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(.init(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = Theme.color.textSecondary
        button.addTar(self, action: #selector(clearTapped))
        button.frame = .init(zeroOrigin: .init(width: 20, height: 20))
        return button
    }
}
