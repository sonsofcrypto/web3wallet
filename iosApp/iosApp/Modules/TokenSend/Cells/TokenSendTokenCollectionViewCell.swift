// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenSendTokenCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tokenTextFieldView: UIView!
    @IBOutlet weak var tokenTextField: TextField!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var tokenMaxButton: UIButton!
    
    private var viewModel: TokenSendViewModel.Token!
    private weak var presenter: TokenSendPresenter!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        tokenTextFieldView.backgroundColor = Theme.colour.labelQuaternary
        tokenTextFieldView.layer.cornerRadius = Theme.constant.cornerRadiusSmall

        tokenTextField.font = Theme.font.title3Bold
        tokenTextField.update(
            placeholder: Localized("tokenSend.cell.token.placeholder")
        )
        tokenTextField.delegate = self
//        tokenTextField.rightView = makeTokenClearButton()
//        tokenTextField.rightViewMode = .whileEditing
        
        tokenLabel.font = Theme.font.body
        tokenLabel.textColor = Theme.colour.labelPrimary
        
        tokenMaxButton.isHidden = true
        tokenMaxButton.tintColor = Theme.colour.labelSecondary
        tokenMaxButton.addTarget(
            self,
            action: #selector(tokenMaxAmountTapped),
            for: .touchUpInside
        )
    }
    
    func update(
        with viewModel: TokenSendViewModel.Token,
        presenter: TokenSendPresenter
    ) {
        
        self.viewModel = viewModel
        self.presenter = presenter
        
        if viewModel.shouldUpdateTextFields, let tokenAmount = viewModel.tokenAmount {
            
            tokenTextField.text = "\(tokenAmount)"
        }
        
        tokenLabel.text = viewModel.tokenSymbol
        
        if viewModel.insufficientFunds {
            
            print("Insufficient funds!!")
        }
    }
}

extension TokenSendTokenCollectionViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == tokenTextField {
            
            tokenMaxButton.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == tokenTextField {
            
            tokenMaxButton.isHidden = true
        }
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
        
        if textField.text == "." {
            textField.text = "0."
        }
        
        guard let text = textField.text, let double = Double(text) else { return }
        presenter.handle(.tokenChanged(to: double))
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
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 24)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 24))
            ]
        )
        return button
    }
    
    @objc func clearTokenTapped() {
        
        tokenTextField.text = nil
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
        
        tokenTextField.text = "\(viewModel.tokenMaxAmount)"
    }
}
