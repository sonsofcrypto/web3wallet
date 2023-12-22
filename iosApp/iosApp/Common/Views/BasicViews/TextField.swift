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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme(Theme)
    }

    func applyTheme(_ theme: ThemeProtocol) {
        font = theme.font.body
        textColor = theme.color.textPrimary
        rightView = makeClearButton()
        backgroundColor = theme.color.bgSecondary
        layer.cornerRadius = theme.cornerRadius.half
        layer.maskedCorners = .all
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: Theme.paddingHalf, dy: Theme.padding * 0.33)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: Theme.paddingHalf, dy: Theme.padding * 0.33)
    }
}

private extension TextField {
    
    func configure() {
        applyTheme(Theme)
        rightViewMode = .whileEditing
        clipsToBounds = true
    }
    
    func placeholderAttrs() -> [NSAttributedString.Key: Any] {
        [
            .font: font ?? Theme.font.body,
            .foregroundColor: Theme.color.textSecondary
        ]
    }
    
    func bodyAttrs() -> [NSAttributedString.Key: Any] {
        [
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


class OldTextField: TextField {

    override func applyTheme(_ theme: ThemeProtocol) {
        font = theme.font.body
        textColor = theme.color.textPrimary
        rightView = makeClearButton()
    }
}
