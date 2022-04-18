// Created by web3d3v on 18/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class AnimatedTextButton: UIButton {

    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var tap: UITapGestureRecognizer!

    private var vStack: VStackView!
    private var hStack: HStackView!
    private var text: [String] = []
    private var isAnimating: Bool = false

    convenience init(
        with text: [String],
        mode: Mode,
        target: AnyObject?,
        action: Selector
    ) {
        self.init(frame: .init(x: 0, y: 0, width: 100, height: 44))
        setText(text)
        setMode(mode, animated: false)
        addTarget(target, action: action, for: .touchUpInside)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    func setText(_ text: [String]) {
        for (idx, str) in text.enumerated() {
            let label = vStack.arrangedSubviews[safe: idx] as? UILabel
                ?? makeTextLabel()
            label.text = str
        }
    }

    func setMode(_ mode: Mode, animated: Bool = true) {
        switch mode {
        case .hidden:
            isAnimating = false
            ()
        case .static:
            isAnimating = false
            ()
        case .animating:
            guard !isAnimating else {
                return
            }

            isAnimating = true
            animate()
        }
    }
}

private extension AnimatedTextButton {

    func configureUI() {

        let iconImageView = UIImageView(image: UIImage(named: "arrow_back"))
        let vStack = VStackView([], alignment: .leading, spacing: 2)
        let hStack = HStackView([iconImageView, vStack], alignment: .center, spacing: 1)

        iconImageView.setContentHuggingPriority(.required, for: .horizontal)

        [self, vStack, hStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = false
        }

        hStack.isUserInteractionEnabled = false

        addSubview(hStack)

        let leadingConstraint = hStack.leadingAnchor.constraint(
            equalTo: leadingAnchor,
            constant: -14
        )

        self.leadingConstraint = leadingConstraint
        self.iconImageView = imageView

        addConstraints([
            hStack.topAnchor.constraint(equalTo: topAnchor),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            leadingConstraint,
            widthAnchor.constraint(equalToConstant: 100),
            heightAnchor.constraint(equalToConstant: 44),
        ])

        self.hStack = hStack
        self.vStack = vStack
    }

    func makeTextLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.font(.gothicA1, style: .medium, size: .caption2)
        label.textColor = Theme.current.tintPrimary
        label.layer.applyShadow(
            Theme.current.tintPrimary,
            radius: Global.shadowRadius
        )
        vStack.addArrangedSubview(label)
        return label
    }
}

// MARK: - Mode

extension AnimatedTextButton {

    enum Mode {
        case hidden
        case `static`
        case animating
    }
}

// MARK: - Animations

extension AnimatedTextButton {

    func animate() {
        let views = [imageView] + vStack.arrangedSubviews
        for (idx, view) in views.enumerated() {
            view?.alpha = 0
            view?.transform = CGAffineTransform(translationX: 100, y: 0)
            UIView.springAnimate(
                1.2,
                delay: 0.1 * CGFloat(idx),
                damping: 0.7,
                velocity: 0.7,
                options: [.allowUserInteraction],
                animations: {
                    view?.transform = .identity
                    view?.alpha = 1
                },
                completion: { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                        guard let animating = self?.isAnimating, animating else {
                            return
                        }
                        UIView.animate(
                            withDuration: 0.2,
                            delay: 0,
                            options: [.allowUserInteraction],
                            animations: {
                                view?.alpha = 0
                                view?.transform = .init(translationX: -50, y: 0)
                            },
                            completion: { _ in
                                guard idx == 0 else {
                                    return
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self?.animate()
                                }
                            }
                        )
                    }
                }
            )
        }
    }
}
