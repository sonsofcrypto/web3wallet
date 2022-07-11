// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenSendTokenCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var availableLabel: UILabel!
    
    @IBOutlet weak var tokenTextFieldView: UIView!
    @IBOutlet weak var tokenTextField: TextField!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var tokenMaxButton: UIButton!

    @IBOutlet weak var currencyTextFieldView: UIView!
    @IBOutlet weak var currencyTextField: TextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyMaxButton: UIButton!
    
    private var viewModel: TokenSendViewModel.Token!
    private weak var presenter: TokenSendPresenter!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        availableLabel.font = Theme.font.bodyBold
        availableLabel.textColor = Theme.colour.labelSecondary
        
        tokenTextFieldView.backgroundColor = Theme.colour.labelQuaternary
        tokenTextFieldView.layer.cornerRadius = Theme.constant.cornerRadiusSmall

        tokenTextField.font = Theme.font.title3Bold
        tokenTextField.placeholderAttrText = Localized("tokenSend.cell.token.placeholder")
        tokenTextField.delegate = self
        tokenTextField.rightView = makeTokenClearButton()
        tokenTextField.rightViewMode = .whileEditing

        tokenLabel.font = Theme.font.body
        tokenLabel.textColor = Theme.colour.labelPrimary
        
        tokenMaxButton.isHidden = false
        tokenMaxButton.tintColor = Theme.colour.labelSecondary
        tokenMaxButton.addTarget(
            self,
            action: #selector(tokenMaxAmountTapped),
            for: .touchUpInside
        )
        
        currencyTextFieldView.backgroundColor = Theme.colour.labelQuaternary
        currencyTextFieldView.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        
        currencyTextField.font = Theme.font.title3Bold
        currencyTextField.textColor = Theme.colour.labelSecondary
        currencyTextField.placeholderAttrText = Localized("tokenSend.cell.currency.placeholder")
        currencyTextField.delegate = self
        currencyTextField.rightView = makeTokenClearButton()
        currencyTextField.rightViewMode = .whileEditing

        currencyLabel.font = Theme.font.body
        currencyLabel.textColor = Theme.colour.labelSecondary
        currencyLabel.text = Localized("tokenSend.cell.currency.label.usd")

        currencyMaxButton.isHidden = false
        currencyMaxButton.tintColor = Theme.colour.labelSecondary
        currencyMaxButton.addTarget(
            self,
            action: #selector(currencyMaxAmountTapped),
            for: .touchUpInside
        )
    }
    
    override func resignFirstResponder() -> Bool {
        
        return tokenTextField.resignFirstResponder() || currencyTextField.resignFirstResponder()
    }
}

extension TokenSendTokenCollectionViewCell {
    
    func update(
        with viewModel: TokenSendViewModel.Token,
        presenter: TokenSendPresenter
    ) {
        
        self.viewModel = viewModel
        self.presenter = presenter
        
        if viewModel.shouldUpdateTextFields, let tokenAmount = viewModel.tokenAmount {
            
            tokenTextField.text = "\(tokenAmount)"
            currencyTextField.text = "\(tokenAmount * viewModel.currencyTokenPrice)"
        }
        
        tokenLabel.text = viewModel.tokenSymbol
        
        if viewModel.insufficientFunds {
            
            print("Insufficient funds!!")
        }
        
        updateAvailableText()
    }
}

extension TokenSendTokenCollectionViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == tokenTextField {
            
            tokenMaxButton.isHidden = false
        } else if textField == currencyTextField {
            
            currencyMaxButton.isHidden = false
        }
        
        updateAvailableText()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == tokenTextField {
            
            tokenMaxButton.isHidden = false
        } else if textField == currencyTextField {
            
            currencyMaxButton.isHidden = false
        }
        
        updateAvailableText()
    }
    
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
        
        if textField == tokenTextField {
            
            if textField.text == "." {
                textField.text = "0."
            }
            
            guard let text = textField.text, let double = Double(text) else { return }
            
            presenter.handle(.tokenChanged(to: double))
            
            updateCurrencyTextField(with: double)
            
        } else if textField == currencyTextField {
            
            if textField.text == "." {
                textField.text = "0."
            }
            
            let currencyAmount = Double(textField.text ?? "") ?? 0
            
            if currencyAmount > 0 {
                tokenTextField.text = "\(currencyAmount/viewModel.currencyTokenPrice)"
            } else {
                tokenTextField.text = nil
            }
            
            presenter.handle(.tokenChanged(to: currencyAmount/viewModel.currencyTokenPrice))
        }
    }
}

private extension TokenSendTokenCollectionViewCell {
    
    func makeTokenClearButton() -> UIButton {
        
        let button = UIButton(type: .system)
        button.setImage(
            .init(systemName: "xmark.circle.fill"),
            for: .normal
        )
        button.tintColor = Theme.colour.labelSecondary
        button.addTarget(self, action: #selector(clearTokenTapped), for: .touchUpInside)
        button.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 20)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 20))
            ]
        )
        return button
    }
        
    @objc func clearTokenTapped() {
        
        tokenTextField.text = nil
        currencyTextField.text = nil
        
        presenter.handle(.tokenChanged(to: 0))
    }
}

private extension TokenSendTokenCollectionViewCell {
    
    @objc func pasteTapped() {
        
        print("Paste tapped")
    }
    
    @objc func qrCodeScanTapped() {
        
        presenter.handle(.qrCodeScan)
    }
    
    @objc func tokenMaxAmountTapped() {
        
        setMaxAmounts()
    }
    
    @objc func currencyMaxAmountTapped() {
        
        setMaxAmounts()
    }
    
    func setMaxAmounts() {
        
        tokenTextField.text = "\(viewModel.tokenMaxAmount)"
        
        let currencyMax = viewModel.tokenMaxAmount * viewModel.currencyTokenPrice
        currencyTextField.text = currencyMax.toString()
    }
    
    func updateCurrencyTextField(with amount: Double) {
        
        if amount > 0 {
            currencyTextField.text = "\(amount * viewModel.currencyTokenPrice)"
        } else {
            currencyTextField.text = nil
        }
    }
    
    func updateAvailableText() {
        
        if tokenTextField.isFirstResponder {
            
            availableLabel.text = makeTokenAvailable()
        } else if currencyTextField.isFirstResponder {
            
            availableLabel.text = makeCurrencyAvailable()
        } else {
            
            availableLabel.text = makeTokenAvailable()
        }
    }
    
    func makeTokenAvailable() -> String {
        
        guard let viewModel = viewModel else { return "" }
        let value = "\(viewModel.tokenMaxAmount) \(viewModel.tokenSymbol)"
        return Localized("tokenSend.cell.available", arg: value)
    }

    func makeCurrencyAvailable() -> String {
        
        guard let viewModel = viewModel else { return "" }
        let value = (viewModel.tokenMaxAmount * viewModel.currencyTokenPrice).formatCurrency() ?? ""
        return Localized("tokenSend.cell.available", arg: value)
    }
}
