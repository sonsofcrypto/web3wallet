// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct TokenEnterAddressViewModel {
    
    let value: String?
    let isValid: Bool
    let becomeFirstResponder: Bool
}

final class TokenEnterAddressView: UIView {
    
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var qrCodeScanButton: UIButton!
    @IBOutlet weak var textField: TextField!
    private weak var pasteButton: UIButton!
    @IBOutlet weak var addContactView: UIView!
    @IBOutlet weak var addContactIcon: UIImageView!
    
    struct Handler {
        
        let onAddressChanged: (String) -> Void
        let onQRCodeScanTapped: () -> Void
        let onPasteTapped: () -> Void
        let onSaveTapped: () -> Void
    }
    
    private var handler: Handler!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        textFieldView.backgroundColor = Theme.colour.cellBackground
        textFieldView.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        qrCodeScanButton.setImage(
            "qrcode.viewfinder".assetImage,
            for: .normal
        )
        qrCodeScanButton.tintColor = Theme.colour.labelPrimary
        qrCodeScanButton.addTarget(self, action: #selector(qrCodeScanTapped), for: .touchUpInside)
        
        textField.placeholderAttrText  = Localized("tokenSend.cell.address.textField.placeholder")
        textField.delegate = self
        textField.rightView = makeClearButton()
        textField.rightViewMode = .whileEditing

        
        let pasteAction = UIButton(type: .custom)
        pasteAction.setTitle(Localized("paste"), for: .normal)
        pasteAction.titleLabel?.font = Theme.font.subheadlineBold
        pasteAction.setTitleColor(Theme.colour.labelPrimary, for: .normal)
        pasteAction.addTarget(self, action: #selector(pasteTapped), for: .touchUpInside)
        pasteAction.addConstraints(
            [
                .hugging(layoutAxis: .horizontal, priority: .required),
                .compression(layoutAxis: .horizontal, priority: .required)
            ]
        )
        if let stackView = textField.superview as? UIStackView {
            stackView.addArrangedSubview(pasteAction)
        }
        self.pasteButton = pasteAction

        addContactView.isHidden = true
        addContactView.add(.targetAction(.init(target: self, selector: #selector(saveTapped))))
        addContactIcon.tintColor = Theme.colour.labelPrimary
    }
    
    override func resignFirstResponder() -> Bool {
        
        return textField.resignFirstResponder()
    }
}

extension TokenEnterAddressView {
    
    func update(
        with address: TokenEnterAddressViewModel,
        handler: Handler
    ) {
        
        self.handler = handler
        
        textField.text = address.value
        
        pasteButton.isHidden = address.isValid
        addContactView.isHidden = !address.isValid
        
        if address.becomeFirstResponder {
            
            textField.becomeFirstResponder()
        }
    }
}

extension TokenEnterAddressView: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        handler.onAddressChanged(textField.text ?? "")
    }
}

private extension TokenEnterAddressView {
    
    @objc func pasteTapped() {

        handler.onPasteTapped()
    }
    
    @objc func qrCodeScanTapped() {
        
        handler.onQRCodeScanTapped()
    }
    
    @objc func saveTapped() {
        
        handler.onSaveTapped()
    }
}

private extension TokenEnterAddressView {
    
    func makeClearButton() -> UIButton {
        
        let button = UIButton(type: .system)
        button.setImage(
            "xmark.circle.fill".assetImage,
            for: .normal
        )
        button.tintColor = Theme.colour.labelSecondary
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        button.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 20)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 20))
            ]
        )
        return button
    }
    
    @objc func clearTapped() {
        
        textField.text = nil
    }
}
