// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT


import UIKit
import web3walletcore

class LabelCell: ThemeCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var trailingLabel: UILabel!
    @IBOutlet weak var accessoryImageView: UIImageView!
    @IBOutlet weak var contentStackView: UIStackView!

    private weak var accessoryType: CellViewModel.Label.Accessory?

    func update(with viewModel: CellViewModel?) -> Self {
        guard let vm = viewModel as? CellViewModel.Label else {
            return self
        }
        label.text = vm.text
        trailingLabel?.text = vm.trailingText
        updateAccessoryView(vm.accessory)
        return self
    }

    override func applyTheme(_ theme: ThemeProtocol) {
        accessoryImageView.tintColor = theme.color.textPrimary
        [label, trailingLabel].forEach {
            $0?.textColor = theme.color.textPrimary
            $0?.font = theme.font.callout
        }
    }

    private func updateAccessoryView(_ accType: CellViewModel.Label.Accessory) {
        guard accType != accessoryType else {
            return
        }
        accessoryType = accType
        switch accType {
        case .detail:
            accessoryImageView.image = UIImage(systemName: "chevron.right")
        case .checkmark:
            accessoryImageView.image = UIImage(systemName: "checkmark")
        case .theCopy:
            accessoryImageView.image = UIImage(systemName: "square.on.square")

        default:
            accessoryImageView.image = nil
        }
    }
}
