// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3lib

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
        let onTokenFromAmountChanged: ((BigInt) -> Void)?
        let onTokenToTapped: (() -> Void)
        let onTokenToAmountChanged: ((BigInt) -> Void)?
        let onSwapFlip: (() -> Void)
        let onProviderTapped: () -> Void
        let onSlippageTapped: () -> Void
        let onNetworkFeesTapped: () -> Void
        let onCTATapped: () -> Void
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        imageView.superview?.layer.cornerRadius = Theme.constant.cornerRadius.half.half
        imageView.superview?.backgroundColor = Theme.colour.cellBackground
        
        imageView.tintColor = Theme.colour.labelSecondary
        imageView.image = "arrow.up.arrow.down".assetImage
        imageView.isHidden = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flip))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        
        loadingIndicator.isHidden = true
        loadingIndicator.color = Theme.colour.activityIndicator
        
        tokenTo.maxButton.isHidden = true
        
        button.style = .primary
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        var configuration = button.configuration ?? .plain()
        configuration.imagePlacement = .trailing
        button.configuration = configuration
        button.updateConfiguration()
        
        stackView.setCustomSpacing(Theme.constant.padding * 1.5, after: tokenTo)
        stackView.setCustomSpacing(Theme.constant.padding.half, after: tokenSwapProviderView)
        stackView.setCustomSpacing(Theme.constant.padding.half, after: tokenSwapPriceView)
        stackView.setCustomSpacing(Theme.constant.padding.half, after: tokenSwapSlippageView)
        stackView.setCustomSpacing(Theme.constant.padding, after: networkFeeView)
    }
    
    override func resignFirstResponder() -> Bool {
        
        tokenFrom.resignFirstResponder() || tokenTo.resignFirstResponder()
    }
    
    func showLoading() {
        
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        imageView.isHidden = true
        setButtonLoading(to: true)
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
            with: viewModel.tokenSwapProviderViewModel,
            handler: .init(onProviderTapped: handler.onProviderTapped)
        )
        
        tokenSwapPriceView.update(
            with: viewModel.tokenSwapPriceViewModel
        )
        
        tokenSwapSlippageView.update(
            with: viewModel.tokenSwapSlippageViewModel,
            handler: .init(onSlippageTapped: handler.onSlippageTapped)
        )
        
        networkFeeView.update(
            with: viewModel.tokenNetworkFeeViewModel,
            handler: handler.onNetworkFeesTapped
        )
        
        switch viewModel.buttonState {
        case let .swap(providerIconName):
            button.setTitle(Localized("tokenSwap.cell.market.swap"), for: .normal)
            button.setImage(
                providerIconName.assetImage?.resize(
                    to: .init(width: 24, height: 24)
                ),
                for: .normal
            )
        case let .insufficientFunds(providerIconName):
            button.setTitle(Localized("insufficientFunds"), for: .normal)
            button.setImage(
                providerIconName.assetImage?.resize(
                    to: .init(width: 24, height: 24)
                ),
                for: .normal
            )
        }
    }
}

private extension TokenSwapMarketCollectionViewCell {
    
    func hideLoading() {
        
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        imageView.isHidden = false
        setButtonLoading(to: false)
    }
    
    @objc func flip() {
        
        handler.onSwapFlip()
    }
    
    @objc func buttonTapped() {
        
        handler.onCTATapped()
    }
    
    func setButtonLoading(to loading: Bool) {
        
        var configuration = button.configuration ?? .plain()
        configuration.imagePlacement = .trailing
        configuration.showsActivityIndicator = loading
        button.configuration = configuration
        button.updateConfiguration()

    }
}
