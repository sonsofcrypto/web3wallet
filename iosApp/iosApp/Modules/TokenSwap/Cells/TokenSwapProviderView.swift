// Created by web3d4v on 17/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct TokenSwapProviderViewModel {
    
    let icon: Data
    let name: String
}

final class TokenSwapProviderView: UIView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    //private var handler: (() -> Void)!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        nameLabel.apply(style: .footnote)
        nameLabel.text = Localized("tokenSwap.cell.provider")
        
        var configuration = UIButton.Configuration.plain()
        configuration.titleTextAttributesTransformer = .init{ incoming in
            var outgoing = incoming
            outgoing.font = Theme.font.footnote
            return outgoing
        }
        configuration.titlePadding = Theme.constant.padding * 0.5
        configuration.imagePadding = Theme.constant.padding * 0.5
        button.configuration = configuration
        button.updateConfiguration()
        button.backgroundColor = .clear
        button.tintColor = Theme.colour.labelPrimary
        button.layer.borderWidth = 0.5
        button.layer.borderColor = Theme.colour.labelPrimary.cgColor
        button.titleLabel?.textAlignment = .natural
        button.layer.cornerRadius = button.frame.size.height.half
        button.setTitleColor(Theme.colour.labelPrimary, for: .normal)
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
        if let leftImage = viewModel.icon.pngImage {
            
            button.setImage(leftImage.resize(to: .init(width: 24, height: 24)), for: .normal)
        }
    }
}

private extension TokenSwapProviderView {
    
    @objc func changeProvider() {
        
        print("Change provider")
    }
}
