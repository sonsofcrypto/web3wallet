// Created by web3d3v on 30/09/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT


import UIKit
import web3walletcore

class NFTsDashboardRefreshCell: ThemeCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var button: Button!

    override func awakeFromNib() {
        super.awakeFromNib()
        button.addTar(self, action: #selector(refreshAction(_:)))
    }

    func update() -> Self {
        titleLabel.text = Localized("nfts.dashboard.noContent.title")
        subTitleLabel.text = Localized("nfts.dashboard.noContent.body")
        button.setTitle(Localized("nfts.dashboard.noContent.cta"), for: .normal)
        return self
    }

    override func applyTheme(_ theme: ThemeProtocol) {
        titleLabel.textColor = theme.color.textPrimary
        subTitleLabel.textColor = theme.color.textPrimary
        titleLabel.font = theme.font.title1
        subTitleLabel.font = theme.font.body
        button.style = .primary
        super.applyTheme(theme)

    }

    @objc func refreshAction(_ sender: Any) {
        guard let cv = collectionView(), let ip = cv.indexPath(for: self) else {
            return
        }
        cv.delegate?.collectionView?(cv, didSelectItemAt: ip)
    }
}
