// Created by web3d4v on 27/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DashboardButtonsCell: UICollectionViewCell {

    struct Handler {
        let onReceive: () -> Void
        let onSend: () -> Void
        let onSwap: () -> Void
    }

    @IBOutlet weak var receiveButton: Button!
    @IBOutlet weak var sendButton: Button!
    @IBOutlet weak var tradeButton: Button!
    @IBOutlet weak var stack: UIStackView!
    
    private var viewModel: [DashboardViewModel.SectionItemsButton] = []
    private var handler: Handler!
        
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
    }
}

private extension DashboardButtonsCell {
    
    func updateViews() {
        viewModel.forEach {
            switch $0.type {
            case .receive:
                receiveButton.style = .dashboardAction(
                    leftImage: $0.imageName.assetImage?.withTintColor(Theme.color.textPrimary)
                )
                receiveButton.setTitle($0.title, for: .normal)
            case .send:
                sendButton.style = .dashboardAction(
                    leftImage: $0.imageName.assetImage?.withTintColor(Theme.color.textPrimary)
                )
                sendButton.setTitle($0.title, for: .normal)
            case .swap:
                tradeButton.style = .dashboardAction(
                    leftImage: $0.imageName.assetImage?.withTintColor(Theme.color.textPrimary)
                )
                tradeButton.setTitle($0.title, for: .normal)
            default:
                break
            }
        }
    }
}

extension DashboardButtonsCell {
    
    @IBAction func receiveTapped() { handler.onReceive() }

    @IBAction func sendTapped() { handler.onSend() }

    @IBAction func tradeTapped() { handler.onSwap() }
}

// MARK: - ViewModel

extension DashboardButtonsCell {

    @discardableResult
    func update(
        with viewModel: [DashboardViewModel.SectionItemsButton],
        handler: Handler
    ) -> Self {
        self.viewModel = viewModel
        self.handler = handler
        updateViews()
        return self
    }
}
