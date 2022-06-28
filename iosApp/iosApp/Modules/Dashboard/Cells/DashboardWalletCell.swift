// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardWalletCell: UICollectionViewCell, ThemeProviding {

    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var topContentStack: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var fiatBalanceLabel: UILabel!
    @IBOutlet weak var pctChangeLabel: UILabel!
    @IBOutlet weak var charView: CandlesView!
    @IBOutlet weak var cryptoBalanceLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
                
        switch theme {
            
        case .themeOG:
            layer.cornerRadius = theme.cornerRadius * 2
        case .themeHome:
            addThemeAScreen()
        }
        
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.5
        imageView.backgroundColor = theme.colour(for: .text)
        
        contentStack.setCustomSpacing(13, after: topContentStack)
        
        currencyLabel.applyStyle(.callout)
        
        pctChangeLabel.applyStyle(.callout)
        
        [fiatBalanceLabel, pctChangeLabel].forEach { $0.applyStyle(.smallLabel) }
        fiatBalanceLabel.textColor = ThemeOG.color.textSecondary
        
        cryptoBalanceLabel.font = theme.font(for: .footnote)
        cryptoBalanceLabel.textColor = theme.colour(for: .orange)

    }

    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        layer.transform = CATransform3DIdentity
        layer.removeAllAnimations()
    }
}

extension DashboardWalletCell {

    func update(with viewModel: DashboardViewModel.Wallet) {
        
        imageView.image = viewModel.imageData.pngImage
        currencyLabel.text = viewModel.name
        fiatBalanceLabel.text = viewModel.fiatBalance
        pctChangeLabel.text = viewModel.pctChange
        pctChangeLabel.textColor = viewModel.priceUp
            ? ThemeOG.color.green
            : ThemeOG.color.red
        pctChangeLabel.layer.shadowColor = pctChangeLabel.textColor.cgColor
        charView.update(viewModel.candles)
        cryptoBalanceLabel.text = viewModel.cryptoBalance
    }
}

private extension DashboardWalletCell {
    
    func addThemeAScreen() {
        
        clipsToBounds = false
        
        // Add screen
        let image = UIImage(named: "themeA-dashboard-screen")!
        let screenView = UIImageView(
            image: image.resizableImage(
                withCapInsets: .init(
                    top: image.size.height * 0.5,
                    left: image.size.width * 0.5,
                    bottom: image.size.height * 0.5,
                    right: image.size.width * 0.5
                ),
                resizingMode: .stretch
            )
        )
        insertSubview(screenView, at: 0)
        screenView.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor, constant: .equalTo(constant: -6)),
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: -4)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: -4))
            ]
        )

        // Add mask
        let maskImage = UIImage(named: "themA-dashboard-mask")!
        let maskView = UIImageView(
            image: maskImage
        )
        screenView.addSubview(maskView)
        maskView.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor, constant: .equalTo(constant: 10)),
                .layout(anchor: .leadingAnchor),
                .layout(anchor: .trailingAnchor)
            ]
        )
    }
}
