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

extension TextField {

    func addDoneToolbar(
        _ target: Any?,
        action: Selector,
        keyboardStyle: Bool = true
    ) {
        let toolbar = addToolbar(keyboardStyle: keyboardStyle)
        let title = Localized("done")
        let items = [
            UIBarButtonItem(system: .flexibleSpace),
            UIBarButtonItem(with: title, target: target, action: action)
        ]
        toolbar.setItems(items, animated: false)
    }

    func addToolbar(keyboardStyle: Bool = false) -> UIToolbar {
        let width = AppDelegate.keyWindow()?.bounds.width ?? 320
        let frame = CGRect(origin: .zero, size: .init(width: width, height: 44))
        let toolbar = UIToolbar(frame: frame)
        if keyboardStyle {
            toolbar.backgroundColor = .clear
            toolbar.setBackgroundImage(
                UIImage(),
                forToolbarPosition: .any,
                barMetrics: .default
            )
            let inputView = UIInputView(frame: frame, inputViewStyle: .keyboard)
            inputView.addSubview(toolbar)
            inputAccessoryView = inputView
        } else {
            inputAccessoryView = toolbar
        }
        return toolbar
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
