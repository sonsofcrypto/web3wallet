// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT


import UIKit
import web3walletcore

class LabelCell: ThemeCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var accessoryImageView: UIImageView!
    @IBOutlet weak var contentStackView: UIStackView!

    private weak var accessoryType: CellViewModel.Label.Accessory?

    func update(with viewModel: CellViewModel?) -> Self {
        guard let vm = viewModel as? CellViewModel.Label else {
            return self
        }
        label.text = vm.text
        updateAccessoryView(vm.accessory)
        return self
    }

    override func applyTheme(_ theme: ThemeProtocol) {
        label.textColor = theme.color.textPrimary
        label.font = theme.font.callout
        accessoryImageView.tintColor = theme.color.textPrimary
    }

    private func updateAccessoryView(_ accType: CellViewModel.Label.Accessory) {
        guard accType != accessoryType else { return }
        accessoryType = accType
        switch accType {
        case .detail:
            accessoryImageView.image = UIImage(systemName: "chevron.right")
        case .checkmark:
            accessoryImageView.image = UIImage(systemName: "checkmark")
        default:
            accessoryImageView.image = nil
        }
    }
}