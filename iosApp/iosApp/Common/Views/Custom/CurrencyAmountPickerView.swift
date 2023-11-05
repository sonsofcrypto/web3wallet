// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit
import web3walletcore

final class CurrencyAmountPickerView: UIView {
    
    @IBOutlet weak var fiatSymbol: UILabel!
    @IBOutlet weak var amountTextField: TextField!
    @IBOutlet weak var flipImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var currencyView: UIView!
    @IBOutlet weak var currencyIconImageView: UIImageView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyDropdownImageView: UIImageView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var maxButton: Button!
    
    private enum Mode {
        case currency
        case fiat
    }
    
    private var viewModel: CurrencyAmountPickerViewModel!
    private var onCurrencyTapped: (() -> Void)?
    private var onAmountChanged: ((BigInt) -> Void)?
    private var mode: Mode = .currency
    
    private var isFlipEvent = false
    private var latestAmount: BigInt?
    private var latestFiatAmount: BigInt?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        backgroundColor = Theme.color.bgPrimary
        layer.cornerRadius = Theme.cornerRadius
        
        fiatSymbol.font = Theme.font.title3
        fiatSymbol.textColor = Theme.color.textPrimary
        fiatSymbol.isHidden = true
        amountTextField.font = Theme.font.title3
        amountTextField.delegate = self
        amountTextField.addDoneToolbarOld(
            with: .targetAction(.init(target: self, selector: #selector(resignFirstResponder)))
        )
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(flipMode))
        flipImageView.image = "arrow.left.arrow.right".assetImage
        flipImageView.tintColor = Theme.color.textPrimary
        flipImageView.isUserInteractionEnabled = true
        flipImageView.addGestureRecognizer(tapGesture1)

        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(flipMode))
        amountLabel.font = Theme.font.footnote
        amountLabel.textColor = Theme.color.textPrimary
        amountLabel.isUserInteractionEnabled = true
        amountLabel.addGestureRecognizer(tapGesture2)
        
        currencyView.backgroundColor = Theme.color.bgPrimary
        currencyView.layer.cornerRadius = Theme.cornerRadius
        let tapGesture = UITapGestureRecognizer(
            target: self, action: #selector(currencyTapped)
        )
        currencyView.addGestureRecognizer(tapGesture)
        currencyIconImageView.layer.cornerRadius = currencyIconImageView.frame.size.width * 0.5
        currencyLabel.apply(style: .body)
        currencyDropdownImageView.image = "chevron.down".assetImage
        currencyDropdownImageView.tintColor = Theme.color.textPrimary

        balanceLabel.font = Theme.font.footnote
        balanceLabel.textColor = Theme.color.textPrimary
        maxButton.style = .secondarySmall(leftImage: nil)
        maxButton.setTitle(Localized("max").uppercased(), for: .normal)
        maxButton.addTarget(self, action: #selector(maxAmountTapped), for: .touchUpInside)
        
    }
    
    override func resignFirstResponder() -> Bool {
        
        return amountTextField.resignFirstResponder()
    }
}

extension CurrencyAmountPickerView {
    
    func update(
        with viewModel: CurrencyAmountPickerViewModel,
        onCurrencyTapped: (() -> Void)? = nil,
        onAmountChanged: ((BigInt) -> Void)? = nil
    ) {
        
        self.viewModel = viewModel
        self.onCurrencyTapped = onCurrencyTapped
        self.onAmountChanged = onAmountChanged
        
        amountTextField.isUserInteractionEnabled = viewModel.inputEnabled
        updatePlaceholder()
        updateSendAmountTextField()
        updateSendAmountLabel()
        updateBalanceLabel()
                
        currencyIconImageView.image = viewModel.symbolIconName.assetImage
        currencyLabel.text = viewModel.symbol
        
        if viewModel.becomeFirstResponder { amountTextField.becomeFirstResponder() }
    }
}

extension CurrencyAmountPickerView: UITextFieldDelegate {
    
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
        case .currency:
            if let decimals = textField.text?.decimals, decimals.count > viewModel.maxDecimals {
                textField.text = textField.text?.stringDroppingLast
                return
            }
            var amount = BigInt.fromString(
                textField.text,
                decimals: UInt(viewModel.maxDecimals)
            )
            // NOTE: This is to not lose precision when flipping between token / fiat values,
            // we store the last tokenAmount and use it later
            if let latestTokenAmount = latestAmount, latestTokenAmount > .zero, isFlipEvent {
                amount = latestTokenAmount
                isFlipEvent = false
            } else {
                isFlipEvent = false
                latestAmount = amount
                onAmountChanged?(amount)
            }
        case .fiat:
            if let decimals = textField.text?.decimals, decimals.count > 2 {
                textField.text = textField.text?.stringDroppingLast
                return
            }
            let fiatAmount = BigInt.fromString(textField.text, decimals: 2)
            var amount = makeAmountFromFiatPrice(with: fiatAmount)
            // NOTE: This is to not lose precision when flipping between token / fiat values,
            // we store the last tokenAmount and use it later
            if let latestTokenAmount = latestAmount, latestTokenAmount > .zero, isFlipEvent {
                amount = latestTokenAmount
                isFlipEvent = false
            } else {
                isFlipEvent = false
                latestAmount = amount
                latestFiatAmount = fiatAmount
                onAmountChanged?(amount)
            }
        }
    }
}

private extension CurrencyAmountPickerView {
    
    func applyTextValidation(to textField: UITextField) {
        if
            viewModel.maxDecimals > 0,
            textField.text == "." || textField.text == ","
        {
            textField.text = "0."
        }
        let totalDots = textField.text?.reduce(into: 0) {
            $0 = $0 + (($1 == "." || $1 == ",") ? 1 : 0)
        } ?? 0
        if
            totalDots > 1,
            let text = textField.text,
            (text.last == "." || text.last == ",")
        {
            var string = text
            _ = string.removeLast()
            textField.text = string
        } else if viewModel.maxDecimals == 0, textField.text == "0" {
            textField.text = ""
        } else if viewModel.maxDecimals > 0, textField.text == "00" {
            textField.text = "0.0"
        } else if textField.text?.contains(",") ?? false {
            textField.text = textField.text?.replacingOccurrences(of: ",", with: ".")
        }
    }
    
    @objc func currencyTapped() {
        onCurrencyTapped?()
    }
}

private extension CurrencyAmountPickerView {
    
    @objc func maxAmountTapped() {
        switch mode {
        case .currency:
            amountTextField.text = viewModel.maxAmount.formatString(
                decimals: UInt(viewModel.maxDecimals)
            )
        case .fiat:
            let maxBalanceAmountFiat = currencyFiatPrice(with: viewModel.maxAmount)
            amountTextField.text = maxBalanceAmountFiat.formatString(decimals: 2)
        }
        latestAmount = viewModel.maxAmount
        onAmountChanged?(viewModel.maxAmount)
    }
    
    func updateSendAmountTextField(isFlip: Bool = false) {
        switch mode {
        case .currency:
            let hasDecimals = viewModel.maxDecimals > 0
            amountTextField.keyboardType = hasDecimals ? .decimalPad : .numberPad
            if isFlip {
                let fiatAmount = BigInt.fromString(amountTextField.text, decimals: 2)
                if fiatAmount == .zero {
                    amountTextField.text = nil
                } else {
                    let amount = latestAmount ?? makeAmountFromFiatPrice(with: fiatAmount)
                    amountTextField.text = amount.formatString(decimals: UInt(viewModel.maxDecimals))
                }
            } else if viewModel.updateTextField {
                let amount = viewModel.amount ?? .zero
                if amount == .zero {
                    amountTextField.text = nil
                } else {
                    amountTextField.text = amount.formatString(decimals: UInt(viewModel.maxDecimals))
                }
            }
            fiatSymbol.isHidden = true
        case .fiat:
            amountTextField.keyboardType = .decimalPad
            if isFlip {
                let amount = latestAmount ?? BigInt.fromString(
                    amountTextField.text,
                    decimals: UInt(viewModel.maxDecimals)
                )
                
                let fiatAmount = latestFiatAmount ?? currencyFiatPrice(with: amount)
                if fiatAmount == .zero {
                    amountTextField.text = nil
                } else {
                    amountTextField.text = fiatAmount.formatString(type: .max, decimals: 2)
                }
            } else if viewModel.updateTextField {
                let amount = viewModel.amount ?? .zero
                let fiatAmount = currencyFiatPrice(with: amount)
                if fiatAmount == .zero {
                    amountTextField.text = nil
                } else {
                    amountTextField.text = fiatAmount.formatString(type: .max, decimals: 2)
                }
            }
            fiatSymbol.isHidden = false
            // TODO: In the future if we want to support EUR or any other local currency we will need to pass here
            // the currency symbol
            fiatSymbol.text = String.currencySymbol(with: "USD")
        }
    }
    
    func updateSendAmountLabel(isFlip: Bool = false) {
        switch mode {
        case .currency:
            if isFlip || isFlipEvent, let latestFiatAmount = latestFiatAmount {
                amountLabel.text = latestFiatAmount.formatStringCurrency(type: .long)
            } else {
                let tokenAmount = BigInt.fromString(
                    amountTextField.text,
                    decimals: UInt(viewModel.maxDecimals)
                )
                let fiatAmount = currencyFiatPrice(with: tokenAmount)
                self.latestFiatAmount = fiatAmount
                amountLabel.text = fiatAmount.formatStringCurrency(type: .long)
            }
        case .fiat:
            let fiatAmount = BigInt.fromString(amountTextField.text, decimals: 2)
            let tokenAmount = isFlip || isFlipEvent
            ? latestAmount ?? makeAmountFromFiatPrice(with: fiatAmount)
            : makeAmountFromFiatPrice(with: fiatAmount)
            amountLabel.text = tokenAmount.formatString(
                type: .long,
                decimals: UInt(viewModel.maxDecimals)
            ) + " \(viewModel.symbol)"
        }
    }
    
    func updateBalanceLabel() {
        switch mode {
        case .currency:
            let arg = viewModel.maxAmount.formatString(
                type: .long,
                decimals: UInt(viewModel.maxDecimals)
            )
            balanceLabel.text = Localized("currencyAmountPicker.balance", arg)
        case .fiat:
            let maxBalanceAmountFiat = currencyFiatPrice(with: viewModel.maxAmount)
            balanceLabel.text = Localized(
                "currencyAmountPicker.balance",
                maxBalanceAmountFiat.formatStringCurrency(type: .max)
            )
        }
    }
    
    func updatePlaceholder() {
        amountTextField.placeholderAttrText = mode == .currency ? "0.0" : "0.00"
    }
    
    @objc func flipMode() {
        isFlipEvent = true
        mode = mode == .currency ? .fiat : .currency
        updateSendAmountTextField(isFlip: true)
        updateSendAmountLabel(isFlip: true)
        updateBalanceLabel()
        updatePlaceholder()
        amountTextField.becomeFirstResponder()
    }
}

private extension CurrencyAmountPickerView {
    
    func currencyFiatPrice(with amount: BigInt) -> BigInt {
        let bigDecBalance = amount.toBigDec(decimals: UInt(viewModel.maxDecimals))
        let bigDecFiatPrice = viewModel.fiatPrice.bigDec
        let bigDecDecimals = Double(100).bigDec
        let result = bigDecBalance.mul(value: bigDecFiatPrice).mul(value: bigDecDecimals)
        return result.toBigInt()
    }
    
    func makeAmountFromFiatPrice(
        with fiatAmount: BigInt
    ) -> BigInt {
        guard viewModel.fiatPrice != .zero else { return .zero }
        let fiatMaxAmount = currencyFiatPrice(with: viewModel.maxAmount)
        guard fiatMaxAmount != fiatAmount else { return viewModel.maxAmount }
        let bigDecFiatAmount = fiatAmount.toBigDec(decimals: 2)
        let bigDecFiatPrice = viewModel.fiatPrice.bigDec
        let tokenDecimalsBigInt = BigInt.Companion().from(uint: 10).pow(value: Int64(viewModel.maxDecimals)
        )
        let result = bigDecFiatAmount.div(value: bigDecFiatPrice).mul(
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
