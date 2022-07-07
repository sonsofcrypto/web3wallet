// Created by web3d4v on 07/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenSendCTACollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var qrCodeScanButton: UIButton!
    @IBOutlet weak var textField: TextField!
    @IBOutlet weak var pasteView: UIView!
    @IBOutlet weak var pasteIcon: UIImageView!
    @IBOutlet weak var pasteLabel: UILabel!
    @IBOutlet weak var addContactView: UIView!
    @IBOutlet weak var addContactIcon: UIImageView!
    
    private weak var presenter: TokenSendPresenter!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        textFieldView.backgroundColor = Theme.colour.labelQuaternary
        textFieldView.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        qrCodeScanButton.setImage(
            .init(systemName: "qrcode.viewfinder"),
            for: .normal
        )
        qrCodeScanButton.tintColor = Theme.colour.labelPrimary
        qrCodeScanButton.addTarget(self, action: #selector(qrCodeScanTapped), for: .touchUpInside)
        
        textField.update(
            placeholder: Localized("tokenSend.cell.address.textField.placeholder")
        )
        textField.delegate = self
        textField.rightView = makeClearButton()
        textField.rightViewMode = .whileEditing

        pasteView.add(.targetAction(.init(target: self, selector: #selector(pasteTapped))))
        pasteIcon.tintColor = Theme.colour.labelPrimary
        pasteLabel.font = Theme.font.bodyBold
        pasteLabel.textColor = Theme.colour.labelPrimary
        pasteLabel.text = Localized("paste")
        
        addContactView.isHidden = true
        addContactIcon.tintColor = Theme.colour.labelPrimary
    }
    
    override func resignFirstResponder() -> Bool {
        
        return textField.resignFirstResponder()
    }
}

extension TokenSendToCollectionViewCell {
    
    func update(
        with address: TokenSendViewModel.Address,
        presenter: TokenSendPresenter
    ) {
        
        self.presenter = presenter
        
        textField.text = address.value
        
        pasteView.isHidden = address.isValid
        addContactView.isHidden = !address.isValid
    }
}

extension TokenSendToCollectionViewCell: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        presenter.handle(.addressChanged(to: textField.text ?? ""))
    }
}

private extension TokenSendToCollectionViewCell {
    
    @objc func pasteTapped() {
        
        presenter.handle(.pasteAddress)
    }
    
    @objc func qrCodeScanTapped() {
        
        presenter.handle(.qrCodeScan)
    }
}

private extension TokenSendToCollectionViewCell {
    
    func makeClearButton() -> UIButton {
        
        let button = UIButton(type: .system)
        button.setImage(
            .init(systemName: "xmark.circle.fill"),
            for: .normal
        )
        button.tintColor = Theme.colour.labelSecondary
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        button.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 24)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 24))
            ]
        )
        return button
    }
    
    @objc func clearTapped() {
        
        textField.text = nil
    }
}
