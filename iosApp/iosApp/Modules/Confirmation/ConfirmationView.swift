// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol ConfirmationView: AnyObject {

    func update(with viewModel: ConfirmationViewModel)
}

final class ConfirmationViewController: BaseViewController {

    var presenter: ConfirmationPresenter!

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var viewModel: ConfirmationViewModel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter?.present()
    }
}

extension ConfirmationViewController: ConfirmationView {

    func update(with viewModel: ConfirmationViewModel) {

        self.viewModel = viewModel
        
        title = viewModel.title
        
        let content = makeContentView()
        view.addSubview(content)
        
        content.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Theme.constant.padding)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Theme.constant.padding)),
                .layout(anchor: .bottomAnchor, constant: .equalTo(constant: Theme.constant.padding))
            ]
        )
    }
}

extension ConfirmationViewController: UIViewControllerTransitioningDelegate, ModalDismissDelegate {

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        
        // Calling here presenter.present() to load the viewModel
        presenter?.present()

        let navBarHeight: CGFloat = 44
        var contentHeight: CGFloat = 0
        
        switch viewModel.content {
            
        case .swap:
            
            contentHeight += navBarHeight
            contentHeight += Theme.constant.padding
            contentHeight += 398
            contentHeight += Theme.constant.padding
            
        case .send:
            
            contentHeight += navBarHeight
            contentHeight += Theme.constant.padding
            contentHeight += 322
            contentHeight += Theme.constant.padding
        }
        
        return ConfirmationSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            contentHeight: contentHeight
        )
    }

    func viewControllerDismissActionPressed(_ viewController: UIViewController?) {
        
        dismissAction()
    }
}

private extension ConfirmationViewController {
    
    func configureUI() {

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .init(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(dismissAction)
        )
    }

    @objc func dismissAction() {
        
        presenter.handle(.dismiss)
    }
}

private extension ConfirmationViewController {
    
    func makeContentView() -> UIView {
        
        switch viewModel.content {
            
        case let .swap(viewModel):
            
            return ConfirmationSwapView(
                viewModel: viewModel,
                onConfirmHandler: makeConfirmationHandler()
            )

        case let .send(viewModel):
            
            return ConfirmationSendView(
                viewModel: viewModel,
                onConfirmHandler: makeConfirmationHandler()
            )
        }
    }
    
    func makeConfirmationHandler() -> () -> Void {
        
        {
            [weak self] in
            guard let self = self else { return }
            self.presenter.handle(.confirm)
        }
    }
}
