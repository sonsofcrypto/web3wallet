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
    private lazy var backgroundView: ThemeBlurView = {
        let view = ThemeBlurView()
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = Theme.cornerRadius
        view.clipsToBounds = true
        insertSubview(view, at: 0)
        return view
    }()
    private lazy var stackView: UIStackView = {
        let stackView = VStackView([], distribution: .fillEqually, spacing: Theme.padding)
        addSubview(stackView)
        return stackView
    }()

    func setButtons(_ buttons: [ButtonViewModel]) {
        while stackView.arrangedSubviews.count > buttons.count
          && !stackView.arrangedSubviews.isEmpty {
            stackView.removeArrangedSubview(stackView.arrangedSubviews.last!)
        }

        while stackView.arrangedSubviews.count < buttons.count {
            let button = UIButton(type: .custom)
            button.backgroundColor = UIColor.red.withAlphaComponent(0.25)
            button.translatesAutoresizingMaskIntoConstraints = false
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

    override func layoutSubviews() {
        super.layoutSubviews()
        var frame = CGRect(zeroOrigin: intrinsicContentSize)
            .insetBy(dx: Theme.padding, dy: 0)
        frame.origin.y = Theme.padding
//        frame.size.height -= Theme.padding
        stackView.frame = frame
        backgroundView.frame = bounds
        stackView.backgroundColor = .green
    }
    
}
