// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenSendToCollectionViewCell: UICollectionViewCell {
    
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
        
        pasteView.add(.targetAction(.init(target: self, selector: #selector(pasteTapped))))
        pasteIcon.tintColor = Theme.colour.labelPrimary
        pasteLabel.font = Theme.font.bodyBold
        pasteLabel.textColor = Theme.colour.labelPrimary
        pasteLabel.text = Localized("paste")
        
        addContactView.isHidden = true
    }
    
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

private extension TokenSendToCollectionViewCell {
    
    @objc func pasteTapped() {
        
        print("Paste tapped")
    }
    
    @objc func qrCodeScanTapped() {
        
        presenter.handle(.qrCodeScan)
    }
}
