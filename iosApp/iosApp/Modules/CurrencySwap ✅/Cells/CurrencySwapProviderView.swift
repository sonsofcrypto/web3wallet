// Created by web3d4v on 17/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct CurrencySwapProviderViewModel {
    
    let iconName: String
    let name: String
}

final class CurrencySwapProviderView: UIView {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var button: Button!
    
    struct Handler {
        let onProviderTapped: (() -> Void)
    }
    
    private var handler: Handler!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.apply(style: .footnote)
        nameLabel.text = Localized("tokenSwap.cell.provider")
        button.style = .secondarySmall(leftImage: nil)
        button.addTarget(
            self,
            action: #selector(changeProvider),
            for: .touchUpInside
        )
    }
}

extension CurrencySwapProviderView {
    
    func update(
        with viewModel: CurrencySwapProviderViewModel,
        handler: Handler
    ) {
        self.handler = handler
        button.setTitle(viewModel.name, for: .normal)
        button.style = .secondarySmall(
            leftImage: viewModel.iconName.assetImage?.resize(
                to: .init(width: 24, height: 24)
            )
        )
    }
}

private extension CurrencySwapProviderView {
    
    @objc func changeProvider() { handler.onProviderTapped() }
}
