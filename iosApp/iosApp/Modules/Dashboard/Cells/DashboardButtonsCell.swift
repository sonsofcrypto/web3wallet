// Created by web3d4v on 27/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DashboardButtonsCell: UICollectionViewCell {

    typealias Handler = ()->Void

    @IBOutlet weak var receiveButton: Button!
    @IBOutlet weak var sendButton: Button!
    @IBOutlet weak var tradeButton: Button!
    @IBOutlet weak var stack: UIStackView!
    
    private var receiveHandler: Handler?
    private var sendHandler: Handler?
    private var swapHandler: Handler?

    override func awakeFromNib() {
        super.awakeFromNib()
        stack.spacing = Theme.padding
    }

    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
}

extension DashboardButtonsCell {
    
    @IBAction func receiveTapped() {
        receiveHandler?()
    }

    @IBAction func sendTapped() {
        sendHandler?()
    }

    @IBAction func tradeTapped() {
        swapHandler?()
    }
}

// MARK: - ViewModel

extension DashboardButtonsCell {

    @discardableResult
    func update(
        with viewModel: [DashboardViewModel.SectionItemsButton],
        receiveHandler: Handler? = nil,
        sendHandler: Handler? = nil,
        swapHandler: Handler? = nil
    ) -> Self {
        self.receiveHandler = receiveHandler
        self.sendHandler = sendHandler
        self.swapHandler = swapHandler

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

        return self
    }
}
