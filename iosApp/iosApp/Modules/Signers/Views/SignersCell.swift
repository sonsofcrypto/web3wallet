// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class SignersCell: CollectionViewCell {
    
    struct Handler {
        let accessoryHandler: (() -> Void)
    }
    
    @IBOutlet weak var indexImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var arrowForward: UIImageView!
    
    private var handler: Handler!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.apply(style: .title3)
        subtitleLabel.apply(style: .footnote)
        subtitleLabel.textColor = Theme.color.textSecondary
        accessoryButton.addTarget(
            self,
            action: #selector(accessoryAction(_:)),
            for: .touchUpInside
        )
        arrowForward.image = UIImage(systemName: "chevron.right")
        accessoryButton.tintColor = Theme.color.textPrimary
        arrowForward.tintColor = Theme.color.textPrimary
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setSelected(isSelected)
    }
}

extension SignersCell {
    
    func update(
        with viewModel: SignersViewModel.Item?,
        handler: Handler,
        index: Int
    ) -> Self {
        self.handler = handler
        let image = UIImage(systemName: "\(index + 1).square.fill")
        let config = UIImage.SymbolConfiguration(
            paletteColors: [
                Theme.color.textPrimary,
                Theme.color.buttonBgPrimary
            ]
        )
        indexImage.image = image.applyingSymbolConfiguration(config)
        titleLabel.text = viewModel?.title
        subtitleLabel.text = viewModel?.address
        subtitleLabel.isHidden = viewModel?.address?.isEmpty ?? true
        return self
    }
}

private extension SignersCell {
    
    @objc func accessoryAction(_ sender: UIButton) {
        handler.accessoryHandler()
    }
}
