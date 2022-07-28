// Created by web3d4v on 17/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct TokenSwapProviderViewModel {
    
    let iconName: String
    let name: String
}

final class TokenSwapProviderView: UIView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var button: Button!
    
    //private var handler: (() -> Void)!
    
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

extension TokenSwapProviderView {
    
    func update(
        with viewModel: TokenSwapProviderViewModel
        //handler: @escaping () -> Void
    ) {
        
        //self.handler = handler

        button.setTitle(viewModel.name, for: .normal)
        button.style = .secondarySmall(
            leftImage: viewModel.iconName.assetImage?.resize(
                to: .init(width: 24, height: 24)
            )
        )
//        if let leftImage = viewModel.icon.pngImage {
//
//            button.style = .secondarySmall(leftImage: )
//            button.setImage(
//                leftImage.withRenderingMode(
//                    .alwaysTemplate
//                ).withTintColor(
//                    Theme.colour.buttonSecondaryText
//                ).resize(
//                    to: .init(width: 24, height: 24)
//                ),
//                for: .normal
//            )
//        }
    }
}

private extension TokenSwapProviderView {
    
    @objc func changeProvider() {
        
        print("Change provider")
    }
}
