// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenSendTokenCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tokenTextFieldView: UIView!
    @IBOutlet weak var tokenTextField: TextField!
    @IBOutlet weak var tokenLabel: UILabel!
    
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
        tokenTextField.rightView = makeTokenClearButton()
        tokenTextField.rightViewMode = .whileEditing

        tokenLabel.font = Theme.font.body
        tokenLabel.textColor = Theme.colour.labelPrimary
    }
    
    func update(
        with token: TokenSendViewModel.Token,
        presenter: TokenSendPresenter
    ) {
        
        self.presenter = presenter
        
        if let tokenAmount = token.tokenAmount {
            tokenTextField.text = "\(tokenAmount)"
        } else {
            tokenTextField.text = nil
        }
        tokenLabel.text = token.tokenSymbol
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
        
        print("selection: \(textField.text)")
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
}
