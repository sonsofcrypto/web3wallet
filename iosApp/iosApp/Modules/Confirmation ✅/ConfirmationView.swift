// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

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

    func update(viewModel__________ viewModel: ConfirmationViewModel) {
        self.viewModel = viewModel
        title = viewModel.title
        view.removeAllSubview()
        let content = contentView()
        view.addSubview(content)
        content.addConstraints(.toEdges(padding: Theme.constant.padding))
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
        contentHeight += navBarHeight
        contentHeight += Theme.constant.padding
        contentHeight += presenter.context().viewContentHeight
        contentHeight += Theme.constant.padding
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
        presenter.handle(event______________: ConfirmationPresenterEvent.Dismiss())
    }
}

private extension ConfirmationViewController {
    
    func contentView() -> UIView {
        if let vm = viewModel.content as? ConfirmationViewModel.ContentTxInProgress {
            return ConfirmationTxInProgressView(viewModel: vm.data)
        }
        if let vm = viewModel.content as? ConfirmationViewModel.ContentTxSuccess {
            return ConfirmationTxSuccessView(
                viewModel: vm.data,
                handler: confirmationTxSuccessViewHandler()
            )
        }
        if let vm = viewModel.content as? ConfirmationViewModel.ContentTxFailed {
            return ConfirmationTxFailedView(
                viewModel: vm.data,
                handler: confirmationTxFailedViewHandler()
            )
        }
        if let vm = viewModel.content as? ConfirmationViewModel.ContentSend {
            return ConfirmationSendView(
                viewModel: vm.data,
                onConfirmHandler: presenterEventTapped(ConfirmationPresenterEvent.Confirm())
            )
        }
        if let vm = viewModel.content as? ConfirmationViewModel.ContentSendNFT {
            return ConfirmationSendNFTView(
                viewModel: vm.data,
                onConfirmHandler: presenterEventTapped(ConfirmationPresenterEvent.Confirm())
            )
        }
        if let vm = viewModel.content as? ConfirmationViewModel.ContentSwap {
            return ConfirmationSwapView(
                viewModel: vm.data,
                onConfirmHandler: presenterEventTapped(ConfirmationPresenterEvent.Confirm())
            )
        }
        if let vm = viewModel.content as? ConfirmationViewModel.ContentCultCastVote {
            return ConfirmationCultCastVoteView(
                viewModel: vm.data,
                onConfirmHandler: presenterEventTapped(ConfirmationPresenterEvent.Confirm())
            )
        }
        if let vm = viewModel.content as? ConfirmationViewModel.ContentApproveUniswap {
            return ConfirmationApproveUniswapView(
                viewModel: vm.data,
                onConfirmHandler: presenterEventTapped(ConfirmationPresenterEvent.Confirm())
            )
        }
        fatalError("View not handled")
    }
    
    func confirmationTxSuccessViewHandler() -> ConfirmationTxSuccessView.Handler {
        .init(
            onCTATapped: presenterEventTapped(ConfirmationPresenterEvent.TxSuccessCTATapped()),
            onCTASecondaryTapped: presenterEventTapped(ConfirmationPresenterEvent.TxSuccessCTASecondaryTapped())
        )
    }
    
    func confirmationTxFailedViewHandler() -> ConfirmationTxFailedView.Handler {
        .init(
            onCTATapped: presenterEventTapped(ConfirmationPresenterEvent.TxFailedCTATapped()),
            onCTASecondaryTapped: presenterEventTapped(ConfirmationPresenterEvent.TxFailedCTASecondaryTapped())
        )
    }
    
    func presenterEventTapped(_ event: ConfirmationPresenterEvent) -> () -> Void {
        { [weak self] in self?.presenter.handle(event______________: event) }
    }
}

private extension ConfirmationWireframeContext {
    var viewContentHeight: CGFloat {
        if (self is ConfirmationWireframeContext.Send) { return 322 }
        else if (self is ConfirmationWireframeContext.Swap) { return 398 }
        else if (self is ConfirmationWireframeContext.SendNFT) { return 342 }
        else if (self is ConfirmationWireframeContext.CultCastVote) { return 312 }
        else if (self is ConfirmationWireframeContext.ApproveUniswap) { return 300 }
        else { return 300 }
    }
}
