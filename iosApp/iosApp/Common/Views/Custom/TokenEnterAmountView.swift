// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

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
            onTokenChanged?(value)
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
            onTokenChanged?(tokenAmount)
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
            let maxAmount = viewModel.tokenMaxAmount * viewModel.currencyTokenPrice
            sendAmountTextField.text = maxAmount.formatString(decimals: viewModel.tokenMaxDecimals)
        }
        
        onTokenChanged?(viewModel.tokenMaxAmount)
    }
    
    func updateSendAmountTextField(forceUpdate: Bool = false) {
        
        switch mode {
        case .token:
            
            let hasDecimals = viewModel.tokenMaxDecimals > 0
            sendAmountTextField.keyboardType = hasDecimals ? .decimalPad : .numberPad
            
            if forceUpdate {
                
                let usdAmount = BigInt.fromString(
                    sendAmountTextField.text,
                    decimals: 2
                )
                if usdAmount == .zero {
                    sendAmountTextField.text = nil
                } else {
                    let tokenAmount = usdAmount / viewModel.currencyTokenPrice
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
            
            if forceUpdate {

                let tokenAmount = BigInt.fromString(
                    sendAmountTextField.text,
                    decimals: viewModel.tokenMaxDecimals
                )
                if tokenAmount == .zero {
                    sendAmountTextField.text = nil
                } else {
                    let value = tokenAmount * viewModel.currencyTokenPrice
                    sendAmountTextField.text = value.formatString(
                        decimals: viewModel.tokenMaxDecimals
                    )
                }
            } else if viewModel.shouldUpdateTextFields {
                
                let tokenAmount = viewModel.tokenAmount ?? .zero
                if tokenAmount == .zero {
                    sendAmountTextField.text = nil
                } else {
                    let value = tokenAmount * viewModel.currencyTokenPrice
                    sendAmountTextField.text = value.formatString(
                        decimals: viewModel.tokenMaxDecimals
                    )
                }
            }
            
            sendCurrencySymbol.isHidden = false
            
            // TODO: In the future if we want to support EUR or any other local currency we will need to pass here
            // the currency symbol
            sendCurrencySymbol.text = String.currencySymbol(with: "USD")
        }
    }
    
    func updateSendAmountLabel() {
        
        switch mode {
            
        case .token:
            let amount = BigInt.fromString(
                sendAmountTextField.text,
                decimals: 2
            )
            let currencyAmount = amount * viewModel.currencyTokenPrice
            sendAmountLabel.text = currencyAmount.formatStringCurrency()
            
        case .usd:
            let amount = BigInt.fromString(
                sendAmountTextField.text,
                decimals: viewModel.tokenMaxDecimals
            )
            let tokenAmount = amount / viewModel.currencyTokenPrice
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
            let maxBalanceAmountUsd = viewModel.tokenMaxAmount * viewModel.currencyTokenPrice
            balanceLabel.text = Localized(
                "tokenSwap.cell.balance",
                arg: maxBalanceAmountUsd.formatStringCurrency()
            )
        }
    }
    
    @objc func flipMode() {
        
        mode = mode == .token ? .usd : .token
        
        updateSendAmountTextField(forceUpdate: true)
        updateSendAmountLabel()
        updateBalanceLabel()
        
        sendAmountTextField.becomeFirstResponder()
    }
}

