// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DashboardActionCell: CollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.backgroundColor = Theme.colour.navBarTint
        imageView.layer.cornerRadius = imageView.bounds.width.half
        titleLabel.apply(style: .footnote)
        bodyLabel.apply(style: .caption1)
        bodyLabel.textColor = Theme.colour.labelSecondary
    }
    
    override func setSelected(_ selected: Bool) {}
}

extension DashboardActionCell {

    func update(with viewModel: DashboardViewModel.SectionItemsAction?) -> Self {
        titleLabel.text = viewModel?.title
        bodyLabel.text = viewModel?.body
        imageView.image = .letterImage(
            viewModel?.image ?? "",
            colors: [Theme.colour.labelPrimary, .clear]
        )
        return self
    }
}
