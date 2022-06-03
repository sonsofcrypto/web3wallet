// Created by web3d4v on 02/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class AppsHeaderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        titleLabel.textColor = Theme.color.text
        titleLabel.font = Theme.font.callout
    }

    func update(with viewModel: AppsViewModel.Item?) {
        
        titleLabel.text = viewModel?.title
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
            return contentView.systemLayoutSizeFitting(CGSize(width: self.bounds.size.width, height: 1))
        }
}
