// Created by web3d3v on 18/11/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

class MnemonicAccountCell: SwipeCollectionViewCell {
    typealias Handler = ()->()
    typealias TextHandler = (_ text: String)->()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: TextField!

    @IBOutlet weak var btnStackView: UIStackView!
    @IBOutlet weak var copyAddressButton: UIButton!
    @IBOutlet weak var viewPrivKeyButton: UIButton!
    
    private var nameHandler: TextHandler?
    private var addressHandler: Handler?
    private var privKeyHandler: Handler?
    private var address: String?
    private var showAsHidden: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        [copyAddressButton, viewPrivKeyButton].forEach {
            $0.titleLabel?.numberOfLines = 1
            $0.titleLabel?.adjustsFontSizeToFitWidth = true
        }
        nameTextField.inputAccessoryView = UIToolbar
            .withDoneButton(self, action: #selector(resignFirstResponder))
            .wrapInInputView()
    }

    override func applyTheme(_ theme: ThemeProtocol) {
        nameLabel?.font = theme.font.callout
        nameLabel?.textColor = theme.color.textPrimary
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let height = copyAddressButton.intrinsicContentSize.height
        btnStackView.bounds.size.height = height
        btnStackView.center.y = btnStackView.superview?.bounds.midY ?? 0
        [nameLabel, nameTextField, btnStackView].forEach {
            $0?.alpha = showAsHidden ? 0.5 : 1
        }
    }

    override func resignFirstResponder() -> Bool {
        nameTextField.resignFirstResponder()
    }

    @IBAction func leadingButtonAction(_ sender: Any) {
        addressHandler?()
        guard let address = self.address else { return }
        animateCopyToPasteboard("\n" + address, maxLines: 3)
    }

    @IBAction func trailingButtonAction(_ sender: Any) {
        privKeyHandler?()
    }
}

extension MnemonicAccountCell: UITextFieldDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {
        nameHandler?(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension MnemonicAccountCell {

    func update(
        with viewModel: CellViewModel.KeyValueList,
        nameHandler: @escaping TextHandler,
        addressHandler: @escaping Handler,
        privKeyHandler: @escaping Handler
    ) -> Self {
        nameLabel.text = viewModel.items.first?.key
        nameTextField.text = viewModel.items.first?.value
        copyAddressButton.setTitle(viewModel.items[1].key, for: .normal)
        viewPrivKeyButton.setTitle(viewModel.items[1].value, for: .normal)
        address = viewModel.items[1].placeholder
        self.nameHandler = nameHandler
        self.addressHandler = addressHandler
        self.privKeyHandler = privKeyHandler
        self.showAsHidden = (viewModel.userInfo?["isHidden"] as? Bool) ?? false
        return self
    }
}
