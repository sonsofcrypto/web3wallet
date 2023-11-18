// Created by web3d3v on 17/11/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol ButtonContainerDelegate: class {
    func buttonContainer(
        _ buttonContainer: ButtonContainer,
        didSelectButtonAt idx: Int
    )
}

class ButtonContainer: UIView, ContentScrollInfo {

    struct ButtonViewModel {
        let title: String
        let style: Style

        enum Style {
            case primary
            case secondary
            case destructive
        }
    }

    weak var delegate: ButtonContainerDelegate?

    private(set) var buttons: [ButtonViewModel] = []
    private weak var backgroundView: ThemeBlurView!
    private weak var stackView: VStackView!
    private var stackHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    func setButtons(_ buttons: [ButtonViewModel]) {
        while stackView.arrangedSubviews.count > buttons.count
          && !stackView.arrangedSubviews.isEmpty {
            stackView.removeArrangedSubview(stackView.arrangedSubviews.last!)
        }

        while stackView.arrangedSubviews.count < buttons.count {
            let button = Button(type: .custom)
            button.addTar(self, action: #selector(buttonAction(_:)))
            stackView.addArrangedSubview(button)
        }

        stackView.arrangedSubviews.enumerated().forEach { idx, view in
            let button = buttons[idx]
            view.tag = idx
            (view as? UIButton)?.setTitle(button.title, for: .normal)
            (view as? Button)?.setButtonViewModelStyle(button.style)
        }
        self.buttons = buttons
        stackHeightConstraint.constant = stackViewHeight()
    }

    @objc func buttonAction(_ sender: UIButton) {
        delegate?.buttonContainer(self, didSelectButtonAt: sender.tag)
    }

    func contentBehindBottomView(_ isBehind: Bool) {
        let alpha = isBehind ? 1.0 : 0.0
        guard alpha != backgroundView.alpha else { return }
        UIView.springAnimate(0.1) { self.backgroundView.alpha = alpha }
    }

    override var intrinsicContentSize: CGSize {
        .init(
            width: (superview ?? AppDelegate.keyWindow())?.bounds.width ?? 320,
            height: CGFloat(buttons.count) * Theme.buttonHeight
                + CGFloat(buttons.count - 1) * Theme.padding
                + Theme.padding
        )
    }

    private func configureUI() {
        let bgView = ThemeBlurView()
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bgView.layer.cornerRadius = Theme.cornerRadius
        bgView.clipsToBounds = true
        addSubview(bgView)
        bgView.contraintToSuperView()
        backgroundView = bgView

        let vStack = VStackView([], distribution: .fillEqually, spacing: Theme.padding)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(vStack)
        let sv = self
        let mrg = Theme.padding
        sv.addConstraints([
            vStack.leadingAnchor.constraint(equalTo: sv.leadingAnchor, constant: mrg),
            vStack.trailingAnchor.constraint(equalTo: sv.trailingAnchor, constant: -mrg),
            vStack.topAnchor.constraint(equalTo: sv.topAnchor, constant: mrg),
        ])
        let heightConst = vStack.heightAnchor.constraint(equalToConstant: mrg)
        stackHeightConstraint = heightConst
        stackView = vStack
    }

    private func stackViewHeight() -> CGFloat {
        CGFloat(buttons.count) * Theme.buttonHeight
            + CGFloat(buttons.count - 1) * Theme.padding
    }
}

