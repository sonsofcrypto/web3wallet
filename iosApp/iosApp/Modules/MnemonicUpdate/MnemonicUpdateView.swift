// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class MnemonicUpdateViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var ctaButton: Button!
    @IBOutlet weak var ctaButtonBottomConstraint: NSLayoutConstraint!

    var presenter: MnemonicUpdatePresenter!

    private var viewModel: MnemonicUpdateViewModel?
    private var didAppear: Bool = false
    private var animatedTransitioning: UIViewControllerAnimatedTransitioning?
    private var interactiveTransitioning: CardFlipInteractiveTransitioning?

    deinit {
        #if DEBUG
        print("[DEBUG][ViewController] deinit \(String(describing: self))")
        #endif
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForBackgroundNotifications()
        configureUI()
        presenter?.present()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
    }
    
    @IBAction func ctaAction(_ sender: Any) {
        presenter.handle(MnemonicUpdatePresenterEvent.Update())
    }
    
    @IBAction func dismissAction(_ sender: Any?) {
        presenter.handle(MnemonicUpdatePresenterEvent.Dismiss())
    }
}

// MARK: - Mnemonic

extension MnemonicUpdateViewController {

    func update(with viewModel: MnemonicUpdateViewModel) {
        let needsReload = self.needsReload(self.viewModel, viewModel: viewModel)
        self.viewModel = viewModel
        guard let cv = collectionView else { return }
        ctaButton.setTitle(viewModel.cta, for: .normal)
        let cells = cv.indexPathsForVisibleItems
        let idxs = IndexSet(0..<viewModel.sections.count)
        if needsReload && didAppear {
            cv.performBatchUpdates { cv.reloadSections(idxs) }
            return
        }
        didAppear
            ? cv.performBatchUpdates { cv.reconfigureItems(at: cells) }
            : cv.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension MnemonicUpdateViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.sections.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.sections[safe: section]?.items.count ?? 0
    }
    

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let item = viewModel?.sections[indexPath.section].items[indexPath.item] else {
            fatalError("Wrong number of items in section \(indexPath)")
        }
        let cell = cell(cv: collectionView, viewModel: item, idxPath: indexPath)
        if indexPath.section == 1 {
            (cell as? CollectionViewCell)?.cornerStyle = .middle
            if indexPath.item == 0 {
                (cell as? CollectionViewCell)?.cornerStyle = .top
            }
            if indexPath.item == (self.viewModel?.sections[safe: 1]?.items.count ?? 0) - 1 {
                (cell as? CollectionViewCell)?.cornerStyle = .bottom
            }
        }
        return cell
    }

    func cell(
        cv: UICollectionView,
        viewModel: MnemonicUpdateViewModel.SectionItem,
        idxPath: IndexPath
    ) -> UICollectionViewCell {
        if let input = viewModel as? MnemonicUpdateViewModel.SectionItemMnemonic {
            return collectionView.dequeue(
                MnemonicUpdateCell.self,
                for: idxPath
            ).update(with: input)
        }
        if let input = viewModel as? MnemonicUpdateViewModel.SectionItemTextInput {
            return collectionView.dequeue(
                TextInputCollectionViewCell.self,
                for: idxPath
            ).update(with: input.viewModel) { [weak self] value in self?.nameDidChange(value) }
        }
        if let input = viewModel as? MnemonicUpdateViewModel.SectionItemSwitch {
            return collectionView.dequeue(
                SwitchCollectionViewCell.self,
                for: idxPath
            ).update(
                with: input.viewModel,
                handler: { [weak self] value in self?.iCloudBackupDidChange(value) }
            )
        }
        if let input = viewModel as? MnemonicUpdateViewModel.SectionItemDelete {
            return collectionView.dequeue(
                MnemonicUpdateDeleteCell.self,
                for: idxPath
            ).update(
                with: input.title,
                handler: makeMnemonicUpdateDeleteCellHandler()
            )
        }
        fatalError("Not implemented")
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            fatalError("Handle header \(kind) \(indexPath)")
        case UICollectionView.elementKindSectionFooter:
            guard let viewModel = viewModel?.sections[indexPath.section].footer else {
                fatalError("Failed to handle \(kind) \(indexPath)")
            }
            let footer = collectionView.dequeue(
                SectionFooterView.self,
                for: indexPath,
                kind: kind
            )
            footer.update(with: viewModel)
            return footer
        default:
            
            fatalError("Failed to handle \(kind) \(indexPath)")
        }
        fatalError("Failed to handle \(kind) \(indexPath)")
    }
}

extension MnemonicUpdateViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        guard indexPath == .init(row: 0, section: 0) else { return false }
        let cell = collectionView.cellForItem(at: .init(item: 0, section: 0))
        (cell as? MnemonicUpdateCell)?.animateCopiedToPasteboard()
        presenter.handle(MnemonicUpdatePresenterEvent.DidTapMnemonic())
        return false
    }

    func nameDidChange(_ name: String) {
        presenter.handle(MnemonicUpdatePresenterEvent.DidChangeName(name: name))
    }

    func iCloudBackupDidChange(_ onOff: Bool) {
        presenter.handle(MnemonicUpdatePresenterEvent.DidChangeICouldBackup(onOff: onOff))
    }
}

extension MnemonicUpdateViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = view.bounds.width - Theme.padding * 2
        guard let viewModel = viewModel?.sections[indexPath.section].items[indexPath.item] else {
            return CGSize(width: width, height: Theme.cellHeight)
        }
        if viewModel is MnemonicUpdateViewModel.SectionItemMnemonic {
            return CGSize(width: width, height: Constant.mnemonicCellHeight)
        }
        if let input = viewModel as? MnemonicUpdateViewModel.SectionItemSwitchWithTextInput {
            return CGSize(
                width: width,
                height: input.viewModel.onOff
                    ? Constant.cellSaltOpenHeight
                    : Constant.cellHeight
            )
        }
        return CGSize(width: width, height: Constant.cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        guard viewModel?.sections[section].footer != nil else { return .zero }
        return .init(width: view.bounds.width, height: Constant.footerHeight)
    }
}

extension MnemonicUpdateViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension MnemonicUpdateViewController: UIViewControllerTransitioningDelegate {

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        let presentedVc = (presented as? UINavigationController)?.topVc
        let sourceNav = (source as? UINavigationController)
        let targetView = (source as? TargetViewTransitionDatasource)?.targetView()
            ?? (sourceNav?.topVc as? TargetViewTransitionDatasource)?.targetView()
            ?? presenting.view
        guard presentedVc == self, let targetView = targetView else {
            animatedTransitioning = nil
            return nil
        }
        animatedTransitioning = CardFlipAnimatedTransitioning(
            targetView: targetView,
            handler: { [weak self] in self?.animatedTransitioning = nil }
        )
        return animatedTransitioning
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard dismissed == self || dismissed == navigationController else {
            animatedTransitioning = nil
            return nil
        }
        let presenting = dismissed.presentingViewController
        guard let visVc = (presenting as? EdgeCardsController)?.visibleViewController,
              let topVc = (visVc as? UINavigationController)?.topVc,
              let targetView = (topVc as? TargetViewTransitionDatasource)?.targetView()
        else {
            animatedTransitioning = nil
            return nil
        }
        animatedTransitioning = CardFlipAnimatedTransitioning(
            targetView: targetView,
            isPresenting: false,
            scaleAdjustment: 0.05,
            handler: { [weak self] in self?.animatedTransitioning = nil }
        )
        return animatedTransitioning
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        interactiveTransitioning
    }

    @objc func handleGesture(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: view.window!)
        let pct = (location.x * 0.5) / view.bounds.width

        switch recognizer.state {
        case .began:
            interactiveTransitioning = CardFlipInteractiveTransitioning(
                handler: { [weak self] in self?.interactiveTransitioning = nil }
            )
            dismiss(animated: true)
        case .changed:
            interactiveTransitioning?.update(pct)
        case .cancelled:
            interactiveTransitioning?.cancel()
        case .ended:
            let completed = recognizer.velocity(in: view.window!).x >= 0
            interactiveTransitioning?.completionSpeed = completed ? 1.5 : 0.1
            completed
                ? interactiveTransitioning?.finish()
                : interactiveTransitioning?.cancel()
        default:
            ()
        }
    }
}

// MARK: - Configure UI

private extension MnemonicUpdateViewController {
    
    func configureUI() {
        title = Localized("mnemonic.title.update")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: "chevron.left".assetImage,
            style: .plain,
            target: self,
            action: #selector(dismissAction(_:))
        )
        collectionView.register(
            MnemonicUpdateDeleteCell.self,
            forCellWithReuseIdentifier: "\(MnemonicUpdateDeleteCell.self)"
        )
        ctaButton.style = .primary
        let edgePan = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(handleGesture(_:))
        )
        edgePan.edges = [UIRectEdge.left]
        view.addGestureRecognizer(edgePan)
        // TODO: Smell
        let window = AppDelegate.keyWindow()
        ctaButtonBottomConstraint.constant = window?.safeAreaInsets.bottom == 0
            ? -Theme.padding
            : 0
    }
    
    func registerForBackgroundNotifications() {
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    @objc func didEnterBackground() {
        presenter.handle(MnemonicUpdatePresenterEvent.Dismiss())
    }
    
    func needsReload(_ preViewModel: MnemonicUpdateViewModel?, viewModel: MnemonicUpdateViewModel) -> Bool {
        preViewModel?.sections[1].items.count != viewModel.sections[1].items.count
    }
    
    func makeMnemonicUpdateDeleteCellHandler() -> MnemonicUpdateDeleteCell.Handler {
        .init(onDelete: mnemonicUpdateDeleteCellOnDelete())
    }
    
    func mnemonicUpdateDeleteCellOnDelete() -> () -> Void {
        { [weak self] in self?.presenter.handle(MnemonicUpdatePresenterEvent.ConfirmDelete()) }
    }
}

// MARK: - Constants

private extension MnemonicUpdateViewController {
    enum Constant {
        static let mnemonicCellHeight: CGFloat = 110
        static let cellHeight: CGFloat = 46
        static let cellSaltOpenHeight: CGFloat = 142
        static let cellPassOpenHeight: CGFloat = 138
        static let footerHeight: CGFloat = 80
    }
}
