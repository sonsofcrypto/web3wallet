// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class AuthenticateViewController: UIViewController, ModalDismissProtocol {
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var saltTextField: TextField!
    @IBOutlet weak var catButton: UIButton!

    var presenter: AuthenticatePresenter!

    weak var modalDismissDelegate: ModalDismissDelegate?
    private var viewModel: AuthenticateViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
}

extension AuthenticateViewController {

    @IBAction func dismissAction(_ sender: Any) {
        presenter.handleEvent(AuthenticatePresenterEvent.DidCancel())
    }

    @IBAction func ctaAction(_ sender: Any) {
        presenter.handleEvent(AuthenticatePresenterEvent.DidConfirm())
    }
}

extension AuthenticateViewController {

    func update(with viewModel: AuthenticateViewModel) {
        navigationController?.view.isHidden = false
        view.isHidden = false
        self.viewModel = viewModel
        title = viewModel.title
        passwordTextField.text = viewModel.password
        passwordTextField.placeholderAttrText = viewModel.passwordPlaceholder
        saltTextField.text = viewModel.salt
        saltTextField.placeholderAttrText = viewModel.saltPlaceholder
        catButton.setTitle(viewModel.title, for: .normal)
        passwordTextField.superview?.isHidden = !viewModel.needsPassword
        saltTextField.superview?.isHidden = !viewModel.needsSalt
        switch viewModel.passType {
        case .pin:
            passwordTextField.keyboardType = .numberPad
        default:
            passwordTextField.keyboardType = .`default`
            passwordTextField.returnKeyType = .done
        }
        passwordTextField.becomeFirstResponder()
    }

    func animateError() {
        navigationController?.view.shakeAnimate()
    }
}

private extension AuthenticateViewController {
    
    func configureUI() {
        title = Localized("authenticate")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            sysImgName: "chevron.left",
            target: self,
            action: #selector(dismissAction(_:))
        )
        passwordTextField.textAlignment = .center
        passwordTextField.superview?.layer.cornerRadius = Theme.cornerRadius.half
        passwordTextField.superview?.backgroundColor = Theme.color.bgPrimary
        saltTextField.textAlignment = .center
        saltTextField.superview?.layer.cornerRadius = Theme.cornerRadius.half
        saltTextField.superview?.backgroundColor = Theme.color.bgPrimary
        navigationController?.view.isHidden = true
        view.isHidden = true
    }
}

extension AuthenticateViewController: UIViewControllerTransitioningDelegate, ModalDismissDelegate {

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        PreferredSizePresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }

    func viewControllerDismissActionPressed(_ viewController: UIViewController?) {
        dismissAction(self)
    }
}

extension AuthenticateViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updatePresenter(textField)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        presenter.handleEvent(AuthenticatePresenterEvent.DidConfirm())
        return false
    }
    
    func updatePresenter(_ textField: UITextField) {
        if textField == passwordTextField {
            presenter.handleEvent(AuthenticatePresenterEvent.DidChangePassword(text: textField.text ?? ""))
        }
        if textField == saltTextField {
            presenter.handleEvent(AuthenticatePresenterEvent.DidChangeSalt(text: textField.text ?? ""))
        }
    }
}
