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
                attributes: placeholder()
            )
        }
    }
}

extension TextField {

    func addDoneToolbarOld(with targetAction: TargetActionViewModel) {
        switch targetAction {
        case let .targetAction(ta):
            addDoneToolbar(ta.target, action: ta.selector)
        }
    }

    func addDoneToolbar(_ target: Any?, action: Selector) {
        let view = UIView(
            frame: .init(
                origin: .zero,
                size: .init(
                    // TODO: Smell
                    width: UIApplication.shared.keyWindow?.frame.size.width ?? 0,
                    height: 40
                )
            )
        )
        view.backgroundColor = Theme.color.navBarBackground
        
        let doneAction = UIButton(type: .custom)
        doneAction.titleLabel?.font = Theme.font.bodyBold
        doneAction.titleLabel?.textAlignment = .right
        doneAction.setTitle(Localized("done"), for: .normal)
        doneAction.setTitleColor(Theme.color.textPrimary, for: .normal)
        doneAction.addTarget(self, action: action, for: .touchUpInside)

        view.addSubview(doneAction)
        doneAction.addConstraints(
            [
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: 16)),
                .layout(anchor: .centerYAnchor)
            ]
        )
        
        inputAccessoryView = view
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
    
    func placeholder() -> [NSAttributedString.Key: Any] {
        [
            .font: font ?? Theme.font.body,
            .foregroundColor: Theme.color.textSecondary
        ]
    }
    
    func body() -> [NSAttributedString.Key: Any] {
        [
            .font: font ?? Theme.font.body,
            .foregroundColor: Theme.color.textPrimary,
//            .shadow: textShadow(Theme.color.fillSecondary)
        ]
    }
    
    func textShadow(_ tint: UIColor) -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowOffset = .zero
        shadow.shadowBlurRadius = Theme.cornerRadiusSmall.half
        shadow.shadowColor = tint
        return shadow
    }
    
    func makeClearButton() -> UIButton {
        
        let button = UIButton(type: .custom)
        button.setImage(
            .init(systemName: "xmark.circle.fill"),
            for: .normal
        )
        button.tintColor = Theme.color.textSecondary
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        button.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 20)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 20))
            ]
        )
        return button
    }
    
    @objc func clearTapped() {
        text = nil
    }
}
