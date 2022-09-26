// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol ConfirmationView: AnyObject {
    func update(with viewModel: ConfirmationViewModel)
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
}

final class ConfirmationViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var presenter: ConfirmationPresenter!

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
        view.removeAllSubview()
        let content = contentView()
        view.addSubview(content)
        content.addConstraints(
            .toEdges(padding: Theme.constant.padding)
        )
    }
}

extension ConfirmationViewController: UIViewControllerTransitioningDelegate, ModalDismissDelegate {

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let navBarHeight: CGFloat = 44
        var contentHeight: CGFloat = 0
        switch presenter.contextType {
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
        case .sendNFT:
            contentHeight += navBarHeight
            contentHeight += Theme.constant.padding
            contentHeight += 342
            contentHeight += Theme.constant.padding
        case .cultCastVote:
            contentHeight += navBarHeight
            contentHeight += Theme.constant.padding
            contentHeight += 270
            contentHeight += Theme.constant.padding
        case .approveUniswap:
            contentHeight += navBarHeight
            contentHeight += Theme.constant.padding
            contentHeight += 300
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
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(dismissAction)
        )
        edgesForExtendedLayout = []
    }

    @objc func dismissAction() {
        presenter.handle(.dismiss)
    }
}

private extension ConfirmationViewController {
    
    func contentView() -> UIView {
        switch viewModel.content {
        case let .inProgress(viewModel):
            return ConfirmationTxInProgressView(
                viewModel: viewModel
            )
        case let .success(viewModel):
            return ConfirmationTxSuccessView(
                viewModel: viewModel,
                handler: confirmationTxSuccessViewHandler()
            )
        case let .failed(viewModel):
            return ConfirmationTxFailedView(
                viewModel: viewModel,
                handler: confirmationTxFailedViewHandler()
            )
        case let .swap(viewModel):
            return ConfirmationSwapView(
                viewModel: viewModel,
                onConfirmHandler: presenterEventTapped(.confirm)
            )
        case let .send(viewModel):
            return ConfirmationSendView(
                viewModel: viewModel,
                onConfirmHandler: presenterEventTapped(.confirm)
            )
        case let .sendNFT(viewModel):
            return ConfirmationSendNFTView(
                viewModel: viewModel,
                onConfirmHandler: presenterEventTapped(.confirm)
            )
        case let .cultCastVote(viewModel):
            return ConfirmationCultCastVoteView(
                viewModel: viewModel,
                onConfirmHandler: presenterEventTapped(.confirm)
            )
        case let .approveUniswap(viewModel):
            return ConfirmationApproveUniswapView(
                viewModel: viewModel,
                onConfirmHandler: presenterEventTapped(.confirm)
            )
        }
    }
    
    func confirmationTxSuccessViewHandler() -> ConfirmationTxSuccessView.Handler {
        .init(
            onCTATapped: presenterEventTapped(.txSuccessCTATapped),
            onCTASecondaryTapped: presenterEventTapped(.txSuccessCTASecondaryTapped)
        )
    }
    
    func confirmationTxFailedViewHandler() -> ConfirmationTxFailedView.Handler {
        .init(
            onCTATapped: presenterEventTapped(.txFailedCTATapped),
            onCTASecondaryTapped: presenterEventTapped(.txFailedCTASecondaryTapped)
        )
    }
    
    func presenterEventTapped(
        _ event: ConfirmationPresenterEvent
    ) -> () -> Void {
        { [weak self] in self?.presenter.handle(event) }
    }
}
