// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenSendTokenCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var sendCurrencySymbol: UILabel!
    @IBOutlet weak var sendAmountTextField: TextField!
    @IBOutlet weak var sendAmountLabel: UILabel!
    @IBOutlet weak var tokenView: UIView!
    @IBOutlet weak var tokenIconImageView: UIImageView!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var tokenDropdownImageView: UIImageView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var maxButton: Button!
    
    private var viewModel: TokenSendViewModel.Token!
    private weak var presenter: TokenSendPresenter!
    
    private var mode: Mode = .token
    
    private enum Mode {
        case token
        case usd
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        cellBackgroundView.backgroundColor = Theme.colour.labelQuaternary
        cellBackgroundView.layer.cornerRadius = Theme.constant.cornerRadius
        
        sendCurrencySymbol.font = Theme.font.title3
        sendCurrencySymbol.textColor = Theme.colour.labelPrimary
        sendCurrencySymbol.isHidden = true
        sendAmountTextField.font = Theme.font.title3
        sendAmountTextField.placeholderAttrText = "0"
        sendAmountTextField.delegate = self
        sendAmountTextField.rightView = makeTokenClearButton()
        sendAmountTextField.rightViewMode = .whileEditing
        sendAmountLabel.font = Theme.font.footnote
        sendAmountLabel.textColor = Theme.colour.labelPrimary
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipMode))
        sendAmountLabel.isUserInteractionEnabled = true
        sendAmountLabel.addGestureRecognizer(tapGesture)
        
        tokenView.backgroundColor = Theme.colour.labelQuaternary
        tokenView.layer.cornerRadius = Theme.constant.cornerRadius
        tokenIconImageView.layer.cornerRadius = tokenIconImageView.frame.size.width * 0.5
        tokenLabel.font = Theme.font.body
        tokenLabel.textColor = Theme.colour.labelPrimary
        tokenDropdownImageView.image = .init(
            systemName: "chevron.down"
        )
        tokenDropdownImageView.tintColor = Theme.colour.labelPrimary
        
        balanceLabel.font = Theme.font.footnote
        balanceLabel.textColor = Theme.colour.labelPrimary
        maxButton.style = .secondarySmall(leftImage: nil)
        maxButton.setTitle(Localized("tokenSend.cell.max"), for: .normal)
        maxButton.addTarget(self, action: #selector(tokenMaxAmountTapped), for: .touchUpInside)
    }
    
    override func resignFirstResponder() -> Bool {
        
        return sendAmountTextField.resignFirstResponder()
    }
}

extension TokenSendTokenCollectionViewCell {
    
    func update(
        with viewModel: TokenSendViewModel.Token,
        presenter: TokenSendPresenter
    ) {
        
        self.viewModel = viewModel
        self.presenter = presenter
        
        updateSendAmountTextField()
        updateSendAmountLabel()
        updateBalanceLabel()
                
        tokenIconImageView.image = viewModel.tokenSymbolIcon.pngImage
        tokenLabel.text = viewModel.tokenSymbol
        
        if viewModel.insufficientFunds {
            
            print("Insufficient funds!!")
        }
    }
}

extension TokenSendTokenCollectionViewCell: UITextFieldDelegate {
    
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
        
        if textField == sendAmountTextField, viewModel.tokenMaxDecimals > 0 {
            
            if textField.text == "." {
                textField.text = "0."
            }
        }
        
        let double = Double(textField.text ?? "0") ?? 0
        
        switch mode {
        case .token:
            presenter.handle(.tokenChanged(to: double))
        case .usd:
            let tokenAmount = double / viewModel.currencyTokenPrice
            presenter.handle(.tokenChanged(to: tokenAmount))
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
        
        sendAmountTextField.text = nil
        
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
        
        switch mode {
        case .token:
            sendAmountTextField.text = viewModel.tokenMaxAmount.toString(
                decimals: viewModel.tokenMaxDecimals
            )
        case .usd:
            let maxAmount = viewModel.tokenMaxAmount * viewModel.currencyTokenPrice
            sendAmountTextField.text = maxAmount.toString()
        }
        
        presenter.handle(.tokenChanged(to: viewModel.tokenMaxAmount))
    }
    
    func updateSendAmountTextField(forceUpdate: Bool = false) {
        
        switch mode {
        case .token:
            
            let hasDecimals = viewModel.tokenMaxDecimals > 0
            sendAmountTextField.keyboardType = hasDecimals ? .decimalPad : .numberPad
            
            if forceUpdate {
                
                let usdAmount = Double(sendAmountTextField.text ?? "0") ?? 0
                if usdAmount == 0 {
                    sendAmountTextField.text = nil
                } else {
                    let tokenAmount = usdAmount / viewModel.currencyTokenPrice
                    sendAmountTextField.text = tokenAmount.toString(
                        decimals: viewModel.tokenMaxDecimals
                    )
                }
            } else if viewModel.shouldUpdateTextFields {
                
                let tokenAmount = viewModel.tokenAmount ?? 0
                sendAmountTextField.text = tokenAmount.toString(
                    decimals: viewModel.tokenMaxDecimals
                )
            }
            
            sendCurrencySymbol.isHidden = true
        case .usd:
            
            sendAmountTextField.keyboardType = .decimalPad
            
            if forceUpdate {
                
                let tokenAmount = Double(sendAmountTextField.text ?? "0") ?? 0
                if tokenAmount == 0 {
                    sendAmountTextField.text = nil
                } else {
                    let value = tokenAmount * viewModel.currencyTokenPrice
                    sendAmountTextField.text = value.toString(
                        decimals: viewModel.tokenMaxDecimals
                    )
                }
            } else if viewModel.shouldUpdateTextFields {
                
                let tokenAmount = viewModel.tokenAmount ?? 0
                if tokenAmount == 0 {
                    sendAmountTextField.text = nil
                } else {
                    let value = tokenAmount * viewModel.currencyTokenPrice
                    sendAmountTextField.text = value.toString(
                        decimals: viewModel.tokenMaxDecimals
                    )
                }
            }
            
            sendCurrencySymbol.isHidden = false
            sendCurrencySymbol.text = 0.formatCurrency(maximumFractionDigits: 0)?.replacingOccurrences(
                of: "0",
                with: ""
            )
        }
        
        if viewModel.shouldUpdateTextFields, let tokenAmount = viewModel.tokenAmount {
            
            sendAmountTextField.text = tokenAmount.toString(decimals: viewModel.tokenMaxDecimals)
        }
    }
    
    func updateSendAmountLabel() {
        
        switch mode {
            
        case .token:
            let amount = Double(sendAmountTextField.text ?? "0") ?? 0
            let currencyAmount = amount * viewModel.currencyTokenPrice
            sendAmountLabel.text = currencyAmount.formatCurrency()
            
        case .usd:
            let amount = Double(sendAmountTextField.text ?? "0") ?? 0
            let tokenAmount = amount / viewModel.currencyTokenPrice
            sendAmountLabel.text = tokenAmount.toString(
                decimals: viewModel.tokenMaxDecimals
            )
        }
    }
    
    func updateBalanceLabel() {
        
        switch mode {
        case .token:
            balanceLabel.text = Localized(
                "tokenSend.cell.balance",
                arg: viewModel.tokenMaxAmount.toString(decimals: viewModel.tokenMaxDecimals)
            )
        case .usd:
            let maxBalanceAmountUsd = viewModel.tokenMaxAmount * viewModel.currencyTokenPrice
            balanceLabel.text = Localized(
                "tokenSend.cell.balance",
                arg: maxBalanceAmountUsd.formatCurrency() ?? ""
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
