// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

final class CurrencySwapMarketCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var currencyFrom: CurrencyAmountPickerView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var currencyTo: CurrencyAmountPickerView!
    @IBOutlet weak var currencySwapProviderView: CurrencySwapProviderView!
    @IBOutlet weak var currencySwapPriceView: CurrencySwapPriceView!
    @IBOutlet weak var currencySwapSlippageView: CurrencySwapSlippageView!
    @IBOutlet weak var networkFeeView: NetworkFeeView!
    @IBOutlet weak var approveButton: Button!
    @IBOutlet weak var button: Button!

    private var handler: Handler!
    
    struct Handler {
        let onCurrencyFromTapped: (() -> Void)
        let onCurrencyFromAmountChanged: ((BigInt) -> Void)?
        let onCurrencyToTapped: (() -> Void)
        let onCurrencyToAmountChanged: ((BigInt) -> Void)?
        let onSwapFlip: (() -> Void)
        let onProviderTapped: () -> Void
        let onSlippageTapped: () -> Void
        let onNetworkFeesTapped: () -> Void
        let onApproveCTATapped: () -> Void
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
        imageView.superview?.superview?.addGestureRecognizer(tapGesture)
        imageView.superview?.superview?.isUserInteractionEnabled = true
        loadingIndicator.isHidden = true
        loadingIndicator.color = Theme.colour.activityIndicator
        currencyTo.maxButton.isHidden = true
        approveButton.style = .primary
        approveButton.addTarget(self, action: #selector(approveButtonTapped), for: .touchUpInside)
        var approveConfiguration = approveButton.configuration ?? .plain()
        approveConfiguration.imagePlacement = .trailing
        approveButton.configuration = approveConfiguration
        approveButton.updateConfiguration()
        button.style = .primary
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        stackView.setCustomSpacing(Theme.constant.padding, after: currencyTo)
        stackView.setCustomSpacing(Theme.constant.padding.half.half, after: currencySwapProviderView)
        stackView.setCustomSpacing(Theme.constant.padding.half.half, after: currencySwapPriceView)
        stackView.setCustomSpacing(Theme.constant.padding.half, after: currencySwapSlippageView)
        stackView.setCustomSpacing(Theme.constant.padding, after: networkFeeView)
    }
    
    override func resignFirstResponder() -> Bool {
        currencyFrom.resignFirstResponder() || currencyTo.resignFirstResponder()
    }
    
    func showLoading() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        imageView.isHidden = true
        setButtonLoading(to: true)
    }
}

extension CurrencySwapMarketCollectionViewCell {
    
    func update(with viewModel: CurrencySwapViewModel.SwapData, handler: Handler) {
        self.handler = handler
        currencyFrom.update(
            with: viewModel.currencyFrom,
            onCurrencyTapped: handler.onCurrencyFromTapped,
            onAmountChanged: {
                [weak self] amount in
                guard let self = self else { return }
                self.showLoading()
                handler.onCurrencyFromAmountChanged?(amount)
            }
        )
        currencyTo.update(
            with: viewModel.currencyTo,
            onCurrencyTapped: handler.onCurrencyToTapped,
            onAmountChanged: {
                [weak self] amount in
                guard let self = self else { return }
                self.showLoading()
                handler.onCurrencyToAmountChanged?(amount)
            }
        )
        currencySwapProviderView.update(
            with: viewModel.currencySwapProviderViewModel,
            handler: .init(onProviderTapped: handler.onProviderTapped)
        )
        currencySwapPriceView.update(
            with: viewModel.currencySwapPriceViewModel
        )
        currencySwapSlippageView.update(
            with: viewModel.currencySwapSlippageViewModel,
            handler: .init(onSlippageTapped: handler.onSlippageTapped)
        )
        networkFeeView.update(
            with: viewModel.currencyNetworkFeeViewModel,
            handler: handler.onNetworkFeesTapped
        )
        if viewModel.isCalculating { showLoading() }
        else { hideLoading() }
        button.setImage(
            viewModel.providerAsset.assetImage?.resize(
                to: .init(width: 24, height: 24)
            ),
            for: .normal
        )
        switch viewModel.approveState {
        case .approve:
            approveButton.isHidden = false
            approveButton.hideLoading()
            approveButton.setTitle(Localized("currencySwap.cell.button.state.approve"), for: .normal)
            approveButton.isEnabled = true
        case .approving:
            approveButton.isHidden = false
            approveButton.showLoading()
            approveButton.setTitle(Localized("currencySwap.cell.button.state.approving"), for: .normal)
            approveButton.isEnabled = true
        case .approved:
            approveButton.isHidden = true
        default:
            break
        }
        if viewModel.buttonState is CurrencySwapViewModel.ButtonStateLoading {
            button.hideLoading()
            button.style = .primary
            button.setTitle(Localized("currencySwap.cell.button.state.swap"), for: .normal)
            button.isEnabled = false
        }
        if let input = viewModel.buttonState as? CurrencySwapViewModel.ButtonStateInvalid {
            button.hideLoading()
            button.style = .primary
            button.setTitle(input.text, for: .normal)
            button.isEnabled = false
        }
        if let input = viewModel.buttonState as? CurrencySwapViewModel.ButtonStateSwapAnyway {
            button.hideLoading()
            button.setTitle(input.text, for: .normal)
            button.style = .primary(action: .destructive)
            button.isEnabled = viewModel.approveState == .approved
        }
        if viewModel.buttonState is CurrencySwapViewModel.ButtonStateSwap {
            button.hideLoading()
            button.setTitle(Localized("currencySwap.cell.button.state.swap"), for: .normal)
            button.style = .primary
            button.isEnabled = viewModel.approveState == .approved
        }
        var configuration = button.configuration ?? .plain()
        configuration.imagePlacement = .trailing
        button.configuration = configuration
        button.updateConfiguration()
    }
}

private extension CurrencySwapMarketCollectionViewCell {
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        imageView.isHidden = false
        setButtonLoading(to: false)
    }
    
    @objc func flip() { handler.onSwapFlip() }
    
    @objc func approveButtonTapped() { handler.onApproveCTATapped() }
    
    @objc func buttonTapped() { handler.onCTATapped() }
    
    func setButtonLoading(to loading: Bool) {
        var configuration = button.configuration ?? .plain()
        configuration.imagePlacement = .trailing
        configuration.showsActivityIndicator = loading
        button.configuration = configuration
        button.updateConfiguration()
    }
}
