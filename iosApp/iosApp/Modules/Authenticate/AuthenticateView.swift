// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AuthenticateView: AnyObject {

    func update(with viewModel: AuthenticateViewModel)
    func animateError()
}

final class AuthenticateViewController: UIViewController, ModalDismissProtocol {

    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var saltTextField: TextField!
    @IBOutlet weak var catButton: UIButton!

    weak var modalDismissDelegate: ModalDismissDelegate?

    var presenter: AuthenticatePresenter!

    private var viewModel: AuthenticateViewModel?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
}

extension AuthenticateViewController {

    @IBAction func dismissAction(_ sender: Any) {
        presenter.handle(.didCancel)
    }

    @IBAction func ctaAction(_ sender: Any) {
        presenter.handle(.didConfirm)
    }
}

extension AuthenticateViewController: AuthenticateView {

    func update(with viewModel: AuthenticateViewModel) {
        // TODO(web3dgn): UI is complete crap. fields to have password type
        // background of this view is crap. Needs to animate up when keyboard
        // comes up. I'd suggest CALayerTransform3D on `view`. I will implement
        // something so that it is automatic on `PreferredSizePresentationControlelr`
        self.viewModel = viewModel
        title = viewModel.title
        passwordTextField.text = viewModel.password
        passwordTextField.placeholderAttrText = viewModel.passwordPlaceholder
        saltTextField.text = viewModel.salt
        saltTextField.placeholderAttrText = viewModel.saltPlaceholder
        catButton.setTitle(viewModel.title, for: .normal)
        passwordTextField.isHidden = !viewModel.needsPassword
        saltTextField.isHidden = !viewModel.needsSalt
    }

    func animateError() {
        navigationController?.view.shakeAnimate()
    }
}

private extension AuthenticateViewController {
    
    func configureUI() {
        
        title = Localized("authenticate")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            with: "chevron.left".assetImage,
            target: self,
            action: #selector(dismissAction(_:))
        )
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

    func textFieldDidEndEditing(_ textField: UITextField) {
        updatePresenter(textField)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updatePresenter(textField)
        textField.resignFirstResponder()
        return false
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        updatePresenter(textField)
        return true
    }

    func updatePresenter(_ textField: UITextField) {
        
        if textField == passwordTextField {
            presenter.handle(.didChangePassword(text: textField.text ?? ""))
        }
        if textField == saltTextField {
            presenter.handle(.didChangeSalt(text: textField.text ?? ""))
        }
    }
}
