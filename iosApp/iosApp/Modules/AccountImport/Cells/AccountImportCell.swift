// Created by web3d3v on 30/12/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class AccountImportCell: ThemeCell {
    typealias InputHandler = (_ text: String) -> Void

    @IBOutlet weak var textView: UITextView?

    private var handler: InputHandler?
    private var needsTextViewConfig: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTextViewIfNeeded()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            configureTextViewIfNeeded()
        }
    }

    override func applyTheme(_ theme: ThemeProtocol) {
        super.applyTheme(theme)
        textView?.applyStyle(.body)
    }

    @objc func doneAction(_ sender: Any) {
        textView?.resignFirstResponder()
    }

    func update(
        with viewModel: AccountImportInputViewModel?,
        handler: @escaping InputHandler
    ) -> Self {
        self.handler = handler
        setErrorStyle(viewModel?.err != nil)
        textView?.textColor = viewModel?.err != nil
            ? Theme.color.navBarTint
            : Theme.color.textPrimary
        return self
    }

    private func configureTextViewIfNeeded() {
        // NOTE: Unknown reason `textView` outlet not connected in `awakeFromNib`
        guard let textView = self.textView, needsTextViewConfig else { return }
        needsTextViewConfig = false
        applyTheme(Theme)
        textView.inputAccessoryView = UIToolbar
            .withDoneButton(self, action: #selector(doneAction(_:)))
            .wrapInInputView()
    }

    func setErrorStyle(_ error: Bool = false) {
        layer.borderWidth = error ? 2 : 0
        layer.borderColor = error ? Theme.color.navBarTint.cgColor : nil
        layer.cornerRadius = Theme.cornerRadius
    }
}

extension AccountImportCell: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        handler?(textView.text)
    }
}
