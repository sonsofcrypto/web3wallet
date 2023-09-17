// Created by web3d4v on 27/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DashboardButtonsCell: UICollectionViewCell {
    @IBOutlet weak var receiveButton: Button!
    @IBOutlet weak var sendButton: Button!
    @IBOutlet weak var tradeButton: Button!
    @IBOutlet weak var stack: UIStackView!

    typealias Handler = ()->Void

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

// MARK: - Actions

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
            var button: Button? = button(for: $0.type)
            button?.setTitle($0.title, for: .normal)
            button?.style = .dashboardAction(
                leftImage: UIImage(named: $0.imageName)
            )
        }

        return self
    }

    private func button(
            for type: DashboardViewModel.SectionItemsButtonType
    ) -> Button? {
        switch type {
        case .receive:
            return receiveButton
        case .send:
            return sendButton
        case .swap:
            return tradeButton
        default:
            return nil
        }
    }
}
