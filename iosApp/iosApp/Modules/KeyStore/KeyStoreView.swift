// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class KeyStoreViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var logoAnimView: LogoAnimView!
    @IBOutlet weak var buttonsCollectionView: UICollectionView!
    @IBOutlet weak var buttonBackgroundView: UIVisualEffectView!
    @IBOutlet weak var buttonHandleView: UIView!
    
    var presenter: KeyStorePresenter!

    private var viewModel: KeyStoreViewModel?
    private var transitionTargetView: KeyStoreViewModel.TransitionTargetView
        = KeyStoreViewModel.TransitionTargetViewNone()
    private var animatedTransitioning: UIViewControllerAnimatedTransitioning?
    private var prevViewSize: CGSize = .zero
    private var needsLayoutUI: Bool = false
    private var viewDidAppear: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
        prevViewSize = view.bounds.size
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if view.bounds.size != prevViewSize {
            [collectionView, buttonsCollectionView].forEach {
                $0.frame = view.bounds
            }
            collectionView.collectionViewLayout.invalidateLayout()
            buttonsCollectionView.collectionViewLayout.invalidateLayout()
            prevViewSize = view.bounds.size
            needsLayoutUI = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if needsLayoutUI {
            configureInsets()
            setButtonsSheetMode(viewModel?.buttons.mode, animated: false)
            layoutButtonsBackground()
            needsLayoutUI = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIntro()
        collectionView.deselectAllExcept(selectedIdxPaths())
        buttonsCollectionView.deselectAllExcept()
        viewDidAppear = true
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        collectionView.collectionViewLayout.invalidateLayout()
        buttonsCollectionView.collectionViewLayout.invalidateLayout()
        needsLayoutUI = true
    }
}

// MARK: - KeyStoreView
extension KeyStoreViewController {

    func update(with viewModel: KeyStoreViewModel) {
        self.viewModel?.buttons.mode != viewModel.buttons.mode
            ? setButtonsSheetMode(viewModel.buttons.mode, animated: false)
            : ()
        self.viewModel = viewModel
        collectionView.reloadData()
        updateLogo(viewModel)
        updateTargetView(targetView: viewModel.targetView)
        buttonsCollectionView.deselectAllExcept()
        collectionView.deselectAllExcept(
            selectedIdxPaths(),
            animated: presentedViewController == nil,
            scrollPosition: .centeredVertically
        )
    }
    
    func updateTargetView(targetView: KeyStoreViewModel.TransitionTargetView) {
        transitionTargetView = targetView
    }
}

// MARK: - UICollectionViewDataSource
extension KeyStoreViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == buttonsCollectionView {
            return viewModel?.buttons.buttons.count ?? 0
        }
        return viewModel?.items.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        switch collectionView {
            
        case buttonsCollectionView:
            let button = viewModel?.buttons.buttons[indexPath.item]
            return collectionView.dequeue(
                ButtonsSheetViewCell.self,
                for: indexPath
            ).update(with: button)
            
        default:
            return collectionView.dequeue(KeyStoreCell.self, for: indexPath)
                .update(
                    with: viewModel?.items[indexPath.item],
                    handler: .init(accessoryHandler: { [weak self] in
                        let event = KeyStorePresenterEvent.DidSelectAccessory(
                            idx: indexPath.item.int32
                        )
                        self?.presenter.handle(event: event)
                    }),
                    index: indexPath.item
                )
        }
    }
}

extension KeyStoreViewController: UICollectionViewDelegate {

    func collectionView(
            _ collectionView: UICollectionView,
            didSelectItemAt indexPath: IndexPath
    ) {
        if collectionView == buttonsCollectionView {
            presenter.handle(
                event: KeyStorePresenterEvent.DidSelectButtonAt(
                    idx: indexPath.item.int32
                )
            )
            return
        }
        presenter.handle(
            event: KeyStorePresenterEvent.DidSelectKeyStoreItemtAt(
                idx: indexPath.item.int32
            )
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        layoutButtonsBackground()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSheetModeIfNeeded(scrollView)
    }
}

extension KeyStoreViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(
            width: view.bounds.width - Theme.padding * 2,
            height: collectionView == buttonsCollectionView
            ? Theme.buttonHeight
            : Theme.cellHeight
        )
    }
}

// MARK: - Configure UI
extension KeyStoreViewController {
    
    func configureUI() {
        title = Localized("wallets")
        collectionView.showsVerticalScrollIndicator = false
        configureInsets()
        buttonBackgroundView.layer.cornerRadius = Theme.cornerRadiusSmall * 2
        buttonBackgroundView.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMinXMinYCorner
        ]
        buttonBackgroundView.contentView.backgroundColor = Theme.color.bgGradientTop.withAlpha(0.4)
        buttonHandleView.backgroundColor = Theme.color.textTertiary
        buttonHandleView.layer.cornerRadius = buttonHandleView.frame.size.height.half
        (view as? ThemeGradientView)?.topClipEnabled = true
    }

    func updateLogo(_ viewModel: KeyStoreViewModel) {
        // Adding first wallet
        if !logoAnimView.isHidden && !viewModel.isEmpty {
            UIView.animate(
                withDuration: 0.6,
                delay: 0.3, animations: { self.logoAnimView.alpha = 0 },
                completion: {_ in self.logoAnimView.isHidden = true }
            )
        // Removing last wallet
        } else if logoAnimView.isHidden && viewModel.isEmpty {
            animateIntro(false)
        // Launching app with wallets
        } else {
            setButtonsSheetMode(.compact, animated: false)
        }
    }

    func selectedIdxPaths() -> [IndexPath] {
        guard let viewModel = viewModel, !viewModel.items.isEmpty else { return [] }
        return viewModel.selectedIdxs.map { IndexPath(item: $0.intValue, section: 0) }
    }
}

// MARK: - ButtonsSheet handling
extension KeyStoreViewController {

    func setButtonsSheetMode(
        _ mode: KeyStoreViewModel.ButtonSheetViewModelSheetMode? = .compact,
        animated: Bool = true
    ) {
        let targetMode = viewDidAppear ? mode : .hidden
        buttonsCollectionView.reloadData()
        guard let mode = targetMode,
              let cv = buttonsCollectionView,
              !cv.isDragging else {
            return
        }
        switch mode {
        case .hidden:
            buttonsCollectionView.setContentOffset(
                CGPoint(x: 0, y: -view.bounds.height),
                animated: false
            )
        case .compact:
            buttonsCollectionView.setContentOffset(
                CGPoint(x: 0, y: -cv.contentInset.top - cv.safeAreaInsets.top),
                animated: animated
            )
        case .expanded:
            let y = view.bounds.height - cv.contentSize.height - cv.safeAreaInsets.bottom
            buttonsCollectionView.setContentOffset(
                CGPoint(x: 0, y: -y),
                animated: animated
            )
        default:
            fatalError("Option not handled")
        }
    }

    func configureInsets() {
        let inset = view.bounds.height
            - Theme.buttonHeight * 3
            - Theme.padding * 4
            - buttonsCollectionView.safeAreaInsets.top
            + 2
        buttonsCollectionView.contentInset.top = inset
        collectionView.contentInset.bottom = view.bounds.height - inset
    }

    func layoutButtonsBackground() {
        guard let topCell = buttonsCollectionView.visibleCells
                .sorted(by: { $0.frame.minY < $1.frame.minY })
                .first else {
            buttonBackgroundView.frame = .zero
            return
        }
        let top = topCell.convert(topCell.bounds.minXminY, to: view)
        buttonBackgroundView.frame = CGRect(
            x: 0,
            y: top.y - Theme.padding * 2,
            width: view.bounds.width,
            height: view.bounds.height - top.y + Theme.padding * 2
        )
        if let cv = buttonsCollectionView {
            let offsetCompact = cv.contentInset.top + cv.safeAreaInsets.top
            let offsetExpanded = view.bounds.height - cv.contentSize.height
                - cv.safeAreaInsets.bottom
            var alpha = (offsetCompact + cv.contentOffset.y)
                / (offsetCompact - offsetExpanded)
            buttonBackgroundView.alpha = min(1, max(0, alpha))
        }
    }

    func updateSheetModeIfNeeded(_ scrollView: UIScrollView) {
        guard scrollView == buttonsCollectionView else { return }
        layoutButtonsBackground()
        guard scrollView.isDragging else { return }
        let cellCount = buttonsCollectionView.visibleCells.count
        presenter.handle(
            event: KeyStorePresenterEvent.DidChangeButtonsSheetMode(
                mode: cellCount > 4 ? .expanded : .compact
            )
        )
    }
}

// MARK: - Into animations
extension KeyStoreViewController {

    func animateIntro(_ animateButtons: Bool = true) {
        guard viewModel?.isEmpty ?? false else {
            return
        }
        logoAnimView.isHidden = false
        logoAnimView.alpha = 0.001
        logoAnimView.animate()
        if animateButtons {
            animateButtonsIntro()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.logoAnimView.alpha = 1
            self?.logoAnimView.animate()
        }
    }

    func animateButtonsIntro() {
        setButtonsSheetMode(.hidden, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) { [weak self] in
            self?.setButtonsSheetMode(.compact, animated: true)
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension KeyStoreViewController: TargetViewTransitionDatasource {

    func targetView() -> UIView {
        if let input = transitionTargetView as? KeyStoreViewModel
            .TransitionTargetViewKeyStoreItemAt {
                let idxPath = IndexPath(item: input.idx.int, section: 0)
                return collectionView.cellForItem(at: idxPath) ?? view
        }
        if let input = transitionTargetView as? KeyStoreViewModel
            .TransitionTargetViewButtonAt {
                let idxPath = IndexPath(item: input.idx.int, section: 0)
                return buttonsCollectionView.cellForItem(at: idxPath) ?? view
        }
        return view
    }
}
