// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class DefaultGradientView: GradientView {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        configureUI()
    }
}

private extension DefaultGradientView {
    
    func configureUI() {
        
        (layer as? CAGradientLayer)?.colors = [
            Theme.color.background,
            Theme.color.backgroundDark
        ]
    }
}
