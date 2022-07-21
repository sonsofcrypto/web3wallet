// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenSwapMarketCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tokenFrom: TokenEnterAmountView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tokenTo: TokenEnterAmountView!
    @IBOutlet weak var tokenSwapProviderView: TokenSwapProviderView!
    @IBOutlet weak var tokenSwapPriceView: TokenSwapPriceView!
    @IBOutlet weak var tokenSwapSlippageView: TokenSwapSlippageView!
    @IBOutlet weak var networkFeeView: TokenNetworkFeeView!
    @IBOutlet weak var button: Button!

    private var handler: Handler!
    
    struct Handler {

        let onTokenFromTapped: (() -> Void)
        let onTokenFromAmountChanged: ((Double) -> Void)?
        let onTokenToTapped: (() -> Void)
        let onTokenToAmountChanged: ((Double) -> Void)?
        let onSwapFlip: (() -> Void)?
        let onNetworkFeesTapped: () -> Void
        let onCTATapped: () -> Void
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        imageView.superview?.layer.cornerRadius = Theme.constant.cornerRadius.half.half
        imageView.superview?.backgroundColor = Theme.colour.cellBackground
        
        imageView.tintColor = Theme.colour.labelSecondary
        imageView.image = .init(systemName: "arrow.up.arrow.down")
        imageView.isHidden = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flip))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        
        loadingIndicator.isHidden = true
        loadingIndicator.color = Theme.colour.labelSecondary
        
        tokenTo.maxButton.isHidden = true
        
        button.style = .primary
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        var configuration = button.configuration ?? .plain()
        configuration.imagePlacement = .trailing
        button.configuration = configuration
        button.updateConfiguration()
        
        stackView.setCustomSpacing(32, after: tokenTo)
        stackView.setCustomSpacing(4, after: tokenSwapProviderView)
        stackView.setCustomSpacing(4, after: tokenSwapPriceView)
        stackView.setCustomSpacing(8, after: tokenSwapSlippageView)
        stackView.setCustomSpacing(16, after: networkFeeView)
    }
    
    override func resignFirstResponder() -> Bool {
        
        tokenFrom.resignFirstResponder() || tokenTo.resignFirstResponder()
    }
    
    func showLoading() {
        
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        imageView.isHidden = true
    }
}

extension TokenSwapMarketCollectionViewCell {
    
    func update(
        with viewModel: TokenSwapViewModel.Swap,
        handler: Handler
    ) {
        
        self.handler = handler
    
        hideLoading()

        tokenFrom.update(
            with: viewModel.tokenFrom,
            onTokenTapped: handler.onTokenFromTapped,
            onTokenChanged: {
                [weak self] amount in
                guard let self = self else { return }
                self.showLoading()
                handler.onTokenFromAmountChanged?(amount)
            }
        )
        
        tokenTo.update(
            with: viewModel.tokenTo,
            onTokenTapped: handler.onTokenToTapped,
            onTokenChanged: {
                [weak self] amount in
                guard let self = self else { return }
                self.showLoading()
                handler.onTokenToAmountChanged?(amount)
            }
        )
        
        tokenSwapProviderView.update(
            with: viewModel.tokenSwapProviderViewModel
        )
        
        tokenSwapPriceView.update(
            with: viewModel.tokenSwapPriceViewModel
        )
        
        tokenSwapSlippageView.update(
            with: viewModel.tokenSwapSlippageViewModel
        )
        
        networkFeeView.update(
            with: viewModel.tokenNetworkFeeViewModel,
            handler: handler.onNetworkFeesTapped
        )
        
        switch viewModel.buttonState {
        case let .swap(providerIcon):
            button.setTitle(Localized("tokenSwap.cell.market.swap"), for: .normal)
            button.setImage(
                providerIcon.pngImage?.resize(
                    to: .init(width: 24, height: 24)
                ),
                for: .normal
            )
            
        case .insufficientFunds:
            button.setTitle(Localized("insufficientFunds"), for: .normal)
        }
    }
}

private extension TokenSwapMarketCollectionViewCell {
    
    func hideLoading() {
        
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        imageView.isHidden = false
    }
    
    @objc func flip() {
        
        handler.onSwapFlip?()
    }
    
    @objc func buttonTapped() {
        
        handler.onCTATapped()
    }
}
