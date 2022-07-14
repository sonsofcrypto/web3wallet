// Created by web3d4v on 02/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class ChatLeftCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var widthLayoutConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        
        super.awakeFromNib()
                
        bubbleView.backgroundColor = Theme.colour.backgroundBasePrimary
        bubbleView.layer.cornerRadius = 8
        bubbleView.addConstraints(
            [
                .compression(axis: .horizontal, priority: .required)
            ]
        )
        
        messageLabel.apply(style: .body)
        messageLabel.textColor = Theme.colour.labelPrimary
        messageLabel.layer.shadowColor = Theme.colour.fillSecondary.cgColor
        messageLabel.layer.shadowOffset = .zero
        messageLabel.layer.shadowRadius = Theme.constant.cornerRadiusSmall.half
        messageLabel.layer.shadowOpacity = 1
    }

    func update(
        with viewModel: ChatViewModel.Item?,
        and width: CGFloat
    ) {

        messageLabel.text = viewModel?.message
        widthLayoutConstraint.constant = width
        
        if viewModel?.isNewMessage ?? false {
            
            bubbleView.animateAsIncomeMessage()
        }
    }
}
