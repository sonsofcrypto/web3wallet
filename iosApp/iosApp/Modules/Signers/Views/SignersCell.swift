// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class SignersCell: SpacedCell {
    typealias Handler = (_ actionIdx: Int)->()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var stack: UIStackView!

    private var firstSet: Bool = false
    private var handler: Handler?

    override func awakeFromNib() {
        super.awakeFromNib()
        applyTheme(Theme)
        buttons().forEach { $0.isHidden = true }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        buttons().forEach { $0.isHidden = true }
    }

    override func applyTheme(_ theme: ThemeProtocol) {
        super.applyTheme(theme)
        self.tintColor = Theme.color.textPrimary
        titleLabel.apply(style: .title3)
        subtitleLabel.apply(style: .footnote)
        subtitleLabel.textColor = Theme.color.textSecondary
    }

    @IBAction func accessoryAction(_ sender: UIButton) {
        handler?(sender.tag)
    }

    private func buttons() -> [UIButton] {
        stack.arrangedSubviews.map { $0 as? UIButton }.compactMap { $0 }
    }
}

extension SignersCell {
    
    func update(
        with viewModel: SignersViewModel.Item?,
        handler: @escaping Handler,
        index: Int
    ) -> Self {
        self.handler = handler
        titleLabel.text = viewModel?.title
        subtitleLabel.text = viewModel?.address
        subtitleLabel.isHidden = viewModel?.address?.isEmpty ?? true
        UIView.springAnimate { self.updateButtons(viewModel?.swipeOptions) }
        return self
    }

    private func updateButtons(
        _ viewModel: [SignersViewModel.ItemSwipeOption]?
    ) {
        guard let viewModel else { return }
        let hideText = viewModel.count == 2
        for (idx, button) in buttons().enumerated() {
            if let vm = viewModel[safe: idx] {
                button.isHidden = false
                button.titleLabel?.text = vm.title()
                button.titleLabel?.isHidden = hideText
                button.imageView?.image = vm.media()?.image()
            } else {
                button.isHidden = true
            }
        }
        // HACK: For some reason on first viewModel set images are not updated
        if !firstSet {
            firstSet = true
            asyncMain(0.05) { [weak self ] in
                self?.stack.setNeedsLayout()
                self?.updateButtons(viewModel)
            }
        }
    }
}

