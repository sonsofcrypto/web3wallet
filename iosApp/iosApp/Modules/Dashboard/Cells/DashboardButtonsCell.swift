// Created by web3d4v on 27/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardButtonsCell: UICollectionViewCell, ThemeProviding {

    @IBOutlet weak var receiveButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tradeButton: UIButton!
    
    private weak var presenter: DashboardPresenter!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        receiveButton.apply(style: .primary)
        sendButton.apply(style: .primary)
        tradeButton.apply(style: .primary)
        
        let view = UIView()
        view.backgroundColor = theme.colour(for: .text)
        addSubview(view)
        view.addConstraints(
            [
                .layout(anchor: .leadingAnchor),
                .layout(anchor: .trailingAnchor),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 0.3)),
                .layout(anchor: .topAnchor)
            ]
        )
    }
}

extension DashboardButtonsCell {
    
    @IBAction func receiveTapped() {
        
        presenter.handle(.receiveAction)
    }

    @IBAction func sendTapped() {
        
        presenter.handle(.sendAction)
    }

    @IBAction func tradeTapped() {
        
        presenter.handle(.tradeAction)
    }
}

extension DashboardButtonsCell {

    func update(with viewModel: [DashboardViewModel.Action], presenter: DashboardPresenter) {
        
        self.presenter = presenter
        
        viewModel.forEach {
            
            switch $0.type {
                
            case .receive:
                receiveButton.setTitle($0.title.uppercased(), for: .normal)
                receiveButton.setImage($0.imageName.assetImage, for: .normal)

            case .send:
                sendButton.setTitle($0.title.uppercased(), for: .normal)
                sendButton.setImage($0.imageName.assetImage, for: .normal)

            case .swap:
                tradeButton.setTitle($0.title.uppercased(), for: .normal)
                tradeButton.setImage($0.imageName.assetImage, for: .normal)
            }
        }
    }
}
