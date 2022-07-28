// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardNotificationCell: CollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    private var viewModel: DashboardViewModel.Notification!
    private var handler: Handler!
    
    struct Handler {
        
        let onDismiss: (String) -> Void
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.cornerRadius = Theme.constant.cornerRadiusSmall * 2
        clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = Theme.colour.navBarTint
        imageView.layer.cornerRadius = 14
        
        titleLabel.apply(style: .footnote)
        bodyLabel.apply(style: .caption1)
        bodyLabel.textColor = Theme.colour.labelSecondary
        
        closeButton.setImage(
            "xmark.circle".assetImage,
            for: .normal
        )
        closeButton.tintColor = Theme.colour.labelPrimary
        closeButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
    }

    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        layer.transform = CATransform3DIdentity
        layer.removeAllAnimations()
    }
}

extension DashboardNotificationCell {

    func update(
        with viewModel: DashboardViewModel.Notification,
        handler: Handler
    ) {
        self.viewModel = viewModel
        self.handler = handler
        
        imageView.image = viewModel.image.pngImage
        titleLabel.text = viewModel.title
        bodyLabel.text = viewModel.body
        
        closeView.isHidden = !viewModel.canDismiss
    }
}

private extension DashboardNotificationCell {
    
    @objc func dismissTapped() {
        
        handler.onDismiss(viewModel.id)
    }
}
