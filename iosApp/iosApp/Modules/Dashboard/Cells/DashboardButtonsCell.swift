// Created by web3d4v on 27/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardButtonsCell: UICollectionViewCell {

    private weak var lineView: UIView!
    @IBOutlet weak var receiveButton: Button!
    @IBOutlet weak var sendButton: Button!
    @IBOutlet weak var tradeButton: Button!
    
    private weak var presenter: DashboardPresenter!
    private var viewModel: [DashboardViewModel.Action] = []

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        let view = UIView()
        addSubview(view)
        view.addConstraints(
            [
                .layout(anchor: .leadingAnchor),
                .layout(anchor: .trailingAnchor),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 0.3)),
                .layout(anchor: .topAnchor)
            ]
        )
        self.lineView = view
        
        updateViews()
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateViews()
    }
}

private extension DashboardButtonsCell {
    
    func updateViews() {

        viewModel.forEach {
            
            switch $0.type {
                
            case .receive:
                receiveButton.style = .dashboardAction(
                    leftImage: $0.imageName.assetImage?.withTintColor(Theme.colour.labelPrimary)
                )
                receiveButton.setTitle($0.title, for: .normal)
            case .send:
                sendButton.style = .dashboardAction(
                    leftImage: $0.imageName.assetImage?.withTintColor(Theme.colour.labelPrimary)
                )
                sendButton.setTitle($0.title, for: .normal)
            case .swap:
                tradeButton.style = .dashboardAction(
                    leftImage: $0.imageName.assetImage?.withTintColor(Theme.colour.labelPrimary)
                )
                tradeButton.setTitle($0.title, for: .normal)
            }
        }
        lineView.backgroundColor = Theme.colour.labelPrimary
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
        self.viewModel = viewModel
        
        updateViews()
    }
}
