// Created by web3d4v on 27/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardButtonsCell: UICollectionViewCell {

    @IBOutlet weak var receiveButton: Button!
    @IBOutlet weak var sendButton: Button!
    @IBOutlet weak var tradeButton: Button!
    @IBOutlet weak var stack: UIStackView!
    
    private weak var presenter: DashboardPresenter!
    private var viewModel: [DashboardViewModel.Action] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        stack.spacing = Theme.constant.padding
        updateViews()
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        backgroundColor = .red
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
        presenter.handle(.swapAction)
    }
}

// MARK: - ViewModel

extension DashboardButtonsCell {

    func update(with viewModel: [DashboardViewModel.Action], presenter: DashboardPresenter) {
        self.viewModel = viewModel
        updateViews()
    }
}
