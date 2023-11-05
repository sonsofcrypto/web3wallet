// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class MnemonicUpdateViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var ctaButton: Button!

    var presenter: MnemonicUpdatePresenter!

    private var viewModel: CollectionViewModel.Screen?
    private var cv: CollectionView! { (collectionView as! CollectionView) }
    private var didAppear: Bool = false
    private var prevSize: CGSize = .zero
    private var cellSize: CGSize = .zero
    private var animatedTransitioning: UIViewControllerAnimatedTransitioning?
    private var interactiveTransitioning: CardFlipInteractiveTransitioning?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        recomputeSizeIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
    }
    
    @IBAction func ctaAction(_ sender: Any) {
        presenter.handleEvent(MnemonicUpdatePresenterEvent.Update())
    }
    
    @IBAction func dismissAction(_ sender: Any?) {
        presenter.handleEvent(MnemonicUpdatePresenterEvent.Dismiss())
    }
}

// MARK: - MnemonicUpdate

extension MnemonicUpdateViewController {

    func update(with viewModel: CollectionViewModel.Screen) {
        let needsReload = needsFullReload(self.viewModel, viewModel: viewModel)
        let needsUpdate = needsSectionsReload(self.viewModel, viewModel: viewModel)

        self.viewModel = viewModel

        guard let cv = collectionView else { return }
        ctaButton.setTitle(viewModel.ctaItems.last, for: .normal)

        let cells = cv.indexPathsForVisibleItems
        let idxs = IndexSet(0..<viewModel.sections.count)

        if needsUpdate && !needsReload && didAppear {
            cv.performBatchUpdates({ cv.reloadSections(idxs) })
            return
        }

        !needsReload && didAppear
            ? cv.performBatchUpdates({ cv.reconfigureItems(at: cells) })
            : cv.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension MnemonicUpdateViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.sections.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel?.sections[safe: section]?.items.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let item = viewModel(at: indexPath) else {
            fatalError("Wrong number of items in section \(indexPath)")
        }
        switch item {
        case let vm as CellViewModel.Text:
            return cv.dequeue(MnemonicUpdateCell.self, for: indexPath)
                .update(with: vm)
        case let vm as CellViewModel.TextInput:
            return cv.dequeue(TextInputCollectionViewCell.self, for: indexPath)
                .update(with: vm) { [weak self] t in self?.nameDidChange(t) }
        case let vm as CellViewModel.Switch:
            return cv.dequeue(SwitchCollectionViewCell.self, for: indexPath)
                .update(with: vm) { [weak self] v in self?.backupDidChange(v) }
        case let vm as CellViewModel.Button:
            return collectionView.dequeue(DeleteCell.self, for: indexPath)
                .update(with: vm) { [weak self] in self?.deleteAction() }
        default:
            fatalError("[MnemonicUpdateView] wrong cellForItemAt \(indexPath)")
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            guard let section = viewModel?.sections[indexPath.section] else {
                fatalError("Failed to handle \(kind) \(indexPath)")
            }
            return cv.dequeue(SectionFooterView.self, for: indexPath, kind: kind)
                .update(with: section)
        default:
            fatalError("Failed to handle \(kind) \(indexPath)")
        }
    }
}

// MARK: - UICollectionViewDelegate

extension MnemonicUpdateViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        guard indexPath == .init(row: 0, section: 0) else { return false }
        let cell = collectionView.cellForItem(at: .init(item: 0, section: 0))
        (cell as? MnemonicUpdateCell)?.animateCopiedToPasteboard()
        presenter.handleEvent(.DidTapMnemonic())
        return false
    }

    func nameDidChange(_ name: String) {
        presenter.handleEvent(.DidChangeName(name: name))
    }

    func backupDidChange(_ onOff: Bool) {
        presenter.handleEvent(.DidChangeICouldBackup(onOff: onOff))
    }

    func deleteAction() {
        presenter.handleEvent(.ConfirmDelete())
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MnemonicUpdateViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let viewModel = viewModel(at: indexPath) else { return cellSize }
        switch viewModel {
        case _ as CellViewModel.Text:
            return CGSize(
                width: cellSize.width,
                height: Constant.mnemonicCellHeight
            )
        case let vm as CellViewModel.SwitchTextInput:
            return CGSize(
                width: cellSize.width,
                height: vm.onOff
                    ? Constant.cellSaltOpenHeight
                    : cellSize.height
            )
        default:
            return cellSize
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        String.estimateSize(
            viewModel?.sections[section].footer?.text(),
            font: Theme.font.sectionFooter,
            maxWidth: cellSize.width,
            extraHeight: Theme.padding
        )
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
            DeleteCell.self,
            forCellWithReuseIdentifier: "\(DeleteCell.self)"
        )
        ctaButton.style = .primary
        let edgePan = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(handleGesture(_:))
        )
        edgePan.edges = [UIRectEdge.left]
        view.addGestureRecognizer(edgePan)
        registerForBackgroundNotifications()
    }
    
    func registerForBackgroundNotifications() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    @objc func didEnterBackground() {
        presenter.handleEvent(MnemonicUpdatePresenterEvent.Dismiss())
    }
    
    func needsReload(
        _ preViewModel: CollectionViewModel.Screen?,
        viewModel: CollectionViewModel.Screen
    ) -> Bool {
        preViewModel?.sections[1].items.count != viewModel.sections[1].items.count
    }

    func viewModel(at idxPath: IndexPath) -> CellViewModel? {
        return viewModel?.sections[idxPath.section].items[idxPath.item]
    }

    func needsSectionsReload(
        _ preViewModel: CollectionViewModel.Screen?,
        viewModel: CollectionViewModel.Screen
    ) -> Bool {
        guard viewModel.sections.count > 1 ||
          (preViewModel?.sections.count ?? 0) > 1 else {
            return false
        }
        return (preViewModel?.sections[safe: 1]?.items.count ?? 0) !=
            (viewModel.sections[safe: 1]?.items.count ?? 0)
    }

    func needsFullReload(
        _ preViewModel: CollectionViewModel.Screen?,
        viewModel: CollectionViewModel.Screen
    ) -> Bool {
        preViewModel?.sections.count != viewModel.sections.count
    }

    func recomputeSizeIfNeeded() {
        guard prevSize.width != view.bounds.size.width else { return }
        prevSize = view.bounds.size
        cellSize = .init(
            width: view.bounds.size.width - Theme.padding * 2,
            height: Theme.cellHeight
        )
    }

}

// MARK: - Constants

private extension MnemonicUpdateViewController {
    enum Constant {
        static let mnemonicCellHeight: CGFloat = 110
        static let cellSaltOpenHeight: CGFloat = 142
        static let cellPassOpenHeight: CGFloat = 138
    }
}
