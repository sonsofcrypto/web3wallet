// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit
import web3lib

struct TokenEnterAmountViewModel {
    
    let tokenAmount: BigInt?
    let tokenSymbolIconName: String
    let tokenSymbol: String
    let tokenMaxAmount: BigInt
    let tokenMaxDecimals: UInt
    let currencyTokenPrice: BigInt
    let shouldUpdateTextFields: Bool
    let shouldBecomeFirstResponder: Bool
    let networkName: String
}

final class TokenEnterAmountView: UIView {
    
    @IBOutlet weak var sendCurrencySymbol: UILabel!
    @IBOutlet weak var sendAmountTextField: TextField!
    @IBOutlet weak var flipImageView: UIImageView!
    @IBOutlet weak var sendAmountLabel: UILabel!
    @IBOutlet weak var tokenView: UIView!
    @IBOutlet weak var tokenIconImageView: UIImageView!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var tokenDropdownImageView: UIImageView!
    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var maxButton: Button!
    
    private enum Mode {
        case token
        case usd
    }
    
    private var viewModel: TokenEnterAmountViewModel!
    private var onTokenTapped: (() -> Void)?
    private var onTokenChanged: ((BigInt) -> Void)?
    private var mode: Mode = .token
    
    private var isFlipEvent = false
    private var latestTokenAmount: BigInt?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        backgroundColor = Theme.colour.cellBackground
        layer.cornerRadius = Theme.constant.cornerRadius
        
        sendCurrencySymbol.font = Theme.font.title3
        sendCurrencySymbol.textColor = Theme.colour.labelPrimary
        sendCurrencySymbol.isHidden = true
        sendAmountTextField.font = Theme.font.title3
        sendAmountTextField.placeholderAttrText = "0"
        sendAmountTextField.delegate = self
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(flipMode))
        flipImageView.image = "arrow.left.arrow.right".assetImage
        flipImageView.tintColor = Theme.colour.labelPrimary
        flipImageView.isUserInteractionEnabled = true
        flipImageView.addGestureRecognizer(tapGesture1)

        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(flipMode))
        sendAmountLabel.font = Theme.font.footnote
        sendAmountLabel.textColor = Theme.colour.labelPrimary
        sendAmountLabel.isUserInteractionEnabled = true
        sendAmountLabel.addGestureRecognizer(tapGesture2)
        
        tokenView.backgroundColor = Theme.colour.labelQuaternary
        tokenView.layer.cornerRadius = Theme.constant.cornerRadius
        let tapGesture = UITapGestureRecognizer(
            target: self, action: #selector(tokenTapped)
        )
        tokenView.addGestureRecognizer(tapGesture)
        tokenIconImageView.layer.cornerRadius = tokenIconImageView.frame.size.width * 0.5
        tokenLabel.apply(style: .body)
        tokenDropdownImageView.image = "chevron.down".assetImage
        tokenDropdownImageView.tintColor = Theme.colour.labelPrimary
        networkLabel.apply(style: .caption2)

        balanceLabel.font = Theme.font.footnote
        balanceLabel.textColor = Theme.colour.labelPrimary
        maxButton.style = .secondarySmall(leftImage: nil)
        maxButton.setTitle(Localized("max").uppercased(), for: .normal)
        maxButton.addTarget(self, action: #selector(tokenMaxAmountTapped), for: .touchUpInside)
        
    }
    
    override func resignFirstResponder() -> Bool {
        
        return sendAmountTextField.resignFirstResponder()
    }
}

extension TokenEnterAmountView {
    
    func update(
        with viewModel: TokenEnterAmountViewModel,
        onTokenTapped: (() -> Void)? = nil,
        onTokenChanged: ((BigInt) -> Void)? = nil
    ) {
        
        self.viewModel = viewModel
        self.onTokenTapped = onTokenTapped
        self.onTokenChanged = onTokenChanged
        
        updateSendAmountTextField()
        updateSendAmountLabel()
        updateBalanceLabel()
                
        tokenIconImageView.image = viewModel.tokenSymbolIconName.assetImage
        tokenLabel.text = viewModel.tokenSymbol
        networkLabel.text = viewModel.networkName
        
        if viewModel.shouldBecomeFirstResponder {
            
            sendAmountTextField.becomeFirstResponder()
        }
    }
}

extension TokenEnterAmountView: UITextFieldDelegate {
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        
        guard textField.text?.contains(".") ?? false else { return true }
        
        guard string != "." else { return false }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        applyTextValidation(to: textField)
        
        switch mode {
        case .token:
            
            if let decimals = textField.text?.decimals, decimals.count > viewModel.tokenMaxDecimals {

                textField.text = textField.text?.stringDroppingLast
                return
            }
            
            let value = BigInt.fromString(
                textField.text,
                decimals: viewModel.tokenMaxDecimals
            )
            
            // NOTE: This is to not lose precision when flipping between token / usd values,
            // we store the last tokenAmount and use it later
            if !isFlipEvent {
                latestTokenAmount = value
            }
            onTokenChanged?(value)
            isFlipEvent = false
        case .usd:
            
            if let decimals = textField.text?.decimals, decimals.count > 2 {
                
                textField.text = textField.text?.stringDroppingLast
                return
            }

            let value = BigInt.fromString(
                textField.text,
                decimals: 2
            )
            let tokenAmount = value / viewModel.currencyTokenPrice
            
            // NOTE: This is to not lose precision when flipping between token / usd values,
            // we store the last tokenAmount and use it later
            if !isFlipEvent {
                latestTokenAmount = tokenAmount
            }
            onTokenChanged?(tokenAmount)
            isFlipEvent = false
        }
    }
}

private extension TokenEnterAmountView {
    
    func applyTextValidation(to textField: UITextField) {
        
        if
            textField == sendAmountTextField,
            viewModel.tokenMaxDecimals > 0,
            textField.text == "."
        {
            textField.text = "0."
        }
        
        if
            viewModel.tokenMaxDecimals == 0,
            textField.text == "0"
        {
            textField.text = ""
        } else if
            viewModel.tokenMaxDecimals > 0,
            textField.text == "00"
        {
            textField.text = "0"
        } else if
            viewModel.tokenMaxDecimals > 0,
            let text = textField.text,
            text.count == 2,
            text[0] == "0",
            text[1] != "."
        {
            textField.text = text[0] + "." + text[1]
        }
    }
    
    @objc func tokenTapped() {
        
        onTokenTapped?()
    }
}

private extension TokenEnterAmountView {
    
    @objc func tokenMaxAmountTapped() {
        
        switch mode {
        case .token:
            sendAmountTextField.text = viewModel.tokenMaxAmount.formatString(
                decimals: viewModel.tokenMaxDecimals
            )
        case .usd:
            let maxBalanceAmountUsd = makeCurrencyUsdPrice(with: viewModel.tokenMaxAmount)
            sendAmountTextField.text = maxBalanceAmountUsd.formatString(decimals: 2)
        }
        
        latestTokenAmount = viewModel.tokenMaxAmount
        
        onTokenChanged?(viewModel.tokenMaxAmount)
    }
    
    func updateSendAmountTextField(isFlip: Bool = false) {
        
        switch mode {
        case .token:
            
            let hasDecimals = viewModel.tokenMaxDecimals > 0
            sendAmountTextField.keyboardType = hasDecimals ? .decimalPad : .numberPad
            
            if isFlip {
                
                let usdAmount = BigInt.fromString(
                    sendAmountTextField.text,
                    decimals: 2
                )
                if usdAmount == .zero {
                    sendAmountTextField.text = nil
                } else {
                    let tokenAmount = makeTokenAmountFromUsdPrice(with: usdAmount)
                    sendAmountTextField.text = tokenAmount.formatString(
                        decimals: viewModel.tokenMaxDecimals
                    )
                }
            } else if viewModel.shouldUpdateTextFields {
                
                let tokenAmount = viewModel.tokenAmount ?? .zero
                if tokenAmount == .zero {
                    sendAmountTextField.text = nil
                } else {
                    sendAmountTextField.text = tokenAmount.formatString(
                        decimals: viewModel.tokenMaxDecimals
                    )
                }
            }
            
            sendCurrencySymbol.isHidden = true
        case .usd:
            
            sendAmountTextField.keyboardType = .decimalPad
            
            if isFlip {

                let tokenAmount = BigInt.fromString(
                    sendAmountTextField.text,
                    decimals: viewModel.tokenMaxDecimals
                )
                
                let usdAmount = makeCurrencyUsdPrice(with: tokenAmount)
                if usdAmount == .zero {
                    sendAmountTextField.text = nil
                } else {
                    sendAmountTextField.text = usdAmount.formatString(
                        type: .max,
                        decimals: 2
                    )
                }
            } else if viewModel.shouldUpdateTextFields {
                
                let tokenAmount = viewModel.tokenAmount ?? .zero
                let usdAmount = makeCurrencyUsdPrice(with: tokenAmount)
                if usdAmount == .zero {
                    sendAmountTextField.text = nil
                } else {
                    sendAmountTextField.text = usdAmount.formatString(
                        type: .max,
                        decimals: 2
                    )
                }
            }
            
            sendCurrencySymbol.isHidden = false
            
            // TODO: In the future if we want to support EUR or any other local currency we will need to pass here
            // the currency symbol
            sendCurrencySymbol.text = String.currencySymbol(with: "USD")
        }
    }
    
    func updateSendAmountLabel(isFlip: Bool = false) {
        
        switch mode {
            
        case .token:
            var tokenAmount = BigInt.fromString(
                sendAmountTextField.text,
                decimals: viewModel.tokenMaxDecimals
            )
            tokenAmount = isFlip || isFlipEvent
            ? latestTokenAmount ?? tokenAmount
            : tokenAmount
            let currencyAmount = makeCurrencyUsdPrice(with: tokenAmount)
            sendAmountLabel.text = currencyAmount.formatStringCurrency()
            
        case .usd:
            let usdAmount = BigInt.fromString(
                sendAmountTextField.text,
                decimals: 2
            )
            let tokenAmount = isFlip || isFlipEvent
            ? latestTokenAmount ?? makeTokenAmountFromUsdPrice(with: usdAmount)
            : makeTokenAmountFromUsdPrice(with: usdAmount)
            sendAmountLabel.text = tokenAmount.formatString(
                decimals: viewModel.tokenMaxDecimals
            ) + " \(viewModel.tokenSymbol)"
        }
    }
    
    func updateBalanceLabel() {
        
        switch mode {
        case .token:
            balanceLabel.text = Localized(
                "tokenSwap.cell.balance",
                arg: viewModel.tokenMaxAmount.formatString(decimals: viewModel.tokenMaxDecimals)
            )
        case .usd:
            let maxBalanceAmountUsd = makeCurrencyUsdPrice(with: viewModel.tokenMaxAmount)
            balanceLabel.text = Localized(
                "tokenSwap.cell.balance",
                arg: maxBalanceAmountUsd.formatStringCurrency()
            )
        }
    }
    
    @objc func flipMode() {
        
        isFlipEvent = true

        mode = mode == .token ? .usd : .token
        
        updateSendAmountTextField(isFlip: true)
        updateSendAmountLabel(isFlip: true)
        updateBalanceLabel()
        
        sendAmountTextField.becomeFirstResponder()
    }
}

private extension TokenEnterAmountView {
    
    func makeCurrencyUsdPrice(
        with amount: BigInt
    ) -> BigInt {
        
        let bigDecBalance = amount.toBigDec(decimals: viewModel.tokenMaxDecimals)
        let bigDecUsdPrice = viewModel.currencyTokenPrice.toBigDec(decimals: 2)
        let bigDecDecimals = BigDec.Companion().from(string: "100", base: 10)

        let result = bigDecBalance.mul(value: bigDecUsdPrice).mul(value: bigDecDecimals)
        
        return result.toBigInt()
    }
    
    func makeTokenAmountFromUsdPrice(
        with usdAmount: BigInt
    ) -> BigInt {
        
        let usdMaxAmount = makeCurrencyUsdPrice(with: viewModel.tokenMaxAmount)
        
        guard usdMaxAmount != usdAmount else { return viewModel.tokenMaxAmount }
        
        let bigDecUsdAmount = usdAmount.toBigDec(decimals: 2)
        let bigDecUsdPrice = viewModel.currencyTokenPrice.toBigDec(decimals: 2)
        
        let tokenDecimalsBigInt = BigInt.Companion().from(uint: 10).pow(value: Int64(viewModel.tokenMaxDecimals))

        let result = bigDecUsdAmount.div(value: bigDecUsdPrice).mul(
            value:  tokenDecimalsBigInt.toBigDec(decimals: 0)
        )
        
        return result.toBigInt()
    }
}

private extension UInt {
    
    var bigDec: BigDec {
        
        BigDec.Companion().from(uint: UInt32(self))
    }
}
