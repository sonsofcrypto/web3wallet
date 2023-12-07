// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class SignersViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var logoAnimView: LogoAnimView!
    @IBOutlet weak var openBetaView: UIStackView!
    
    var presenter: SignersPresenter!

    private var viewModel: SignersViewModel?
    private var cv: CollectionView! { (collectionView as! CollectionView) }
    private var ctaButtonsContainer: ButtonSheetContainer = .init()
    private var transitionTargetView: SignersViewModel.TransitionTargetView
        = SignersViewModel.TransitionTargetViewNone()
    private var animatedTransitioning: UIViewControllerAnimatedTransitioning?
    private var didAppear: Bool = false
    private var prevSize: CGSize = .zero
    private var cellSize: CGSize = .zero

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
        prevSize = view.bounds.size
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if view.bounds.size != prevSize {
            prevSize = view.bounds.size
            collectionView.collectionViewLayout.invalidateLayout()
            layoutAboveScrollView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel?.isEmpty ?? true && !didAppear {
            ctaButtonsContainer.isHidden = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIntro()
        collectionView.deselectAllExcept(selectedIdxPaths())
        didAppear = true
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        collectionView.collectionViewLayout.invalidateLayout()
        layoutAboveScrollView()
    }
}

// MARK: - KeyStoreView

extension SignersViewController {

    func update(with viewModel: SignersViewModel) {
        self.viewModel = viewModel
        updateTargetView(targetView: viewModel.targetView)
        collectionView.reloadData()
        updateLogo(viewModel)
        collectionView.deselectAllExcept(
            selectedIdxPaths(),
            animated: presentedViewController == nil,
            scrollPosition: .centeredVertically
        )
        ctaButtonsContainer.setButtons(
            viewModel.buttons,
            compactCount: 3,
            sheetState: .auto,
            animated: true,
            expandedButton: viewModel.expandedButtons
        )
        UIView.springAnimate { self.layoutAboveScrollView() }
        ctaButtonsContainer.minimizeBgHeight = !viewModel.items.isEmpty
    }
    
    func updateTargetView(targetView: SignersViewModel.TransitionTargetView) {
        transitionTargetView = targetView
    }

    func updateCTASheet(expanded: Bool) {
        ctaButtonsContainer.setSheetState(expanded ? .expanded : .compact)
    }
}

// MARK: - UICollectionViewDataSource

extension SignersViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel?.items.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
         collectionView.dequeue(SignersCell.self, for: indexPath)
            .update(
                with: viewModel?.items[indexPath.item],
                handler: { [weak self] in self?.accessoryAction(indexPath) },
                index: indexPath.item
            )
    }
}

extension SignersViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        presenter.handleEvent(.SignerAction(idx: indexPath.item.int32))
    }

    func accessoryAction(_ idxPath: IndexPath) {
        presenter.handleEvent(.AccessoryAction(idx: idxPath.item.int32))
    }
}

extension SignersViewController: ButtonSheetContainerDelegate {

    func buttonSheetContainer(_ bsc: ButtonSheetContainer, didSelect idx: Int) {
        presenter.handleEvent(.ButtonAction(idx: idx.int32))
    }

    func buttonSheetContainer(_ bsc: ButtonSheetContainer, expanded: Bool) {
        presenter.handleEvent(.SetCTASheet(expanded: expanded))
        let bscHeight = bsc.intrinsicContentSize.height
        let initialOffset = cv.contentOffset
        cv.contentInset.bottom = expanded ? bscHeight : bscHeight / 2
        // HACK: This dance is required to force sheet layout prio animation to
        // avoid wierd UI glitch.
        let targetOffset = cv.contentOffset
        cv.setContentOffset(initialOffset, animated: false)
        cv.setContentOffset(targetOffset, animated: true)
    }
}

extension SignersViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(
            width: view.bounds.width - Theme.padding * 2,
            height: Theme.cellHeightLarge
        )
    }
}

// MARK: - Configure UI
extension SignersViewController {
    
    func configureUI() {
        title = Localized("wallets")
        collectionView.backgroundView = nil
        collectionView.showsVerticalScrollIndicator = false
        (view as? ThemeGradientView)?.topClipEnabled = true

        ctaButtonsContainer.hideBgForNonExpanded = true
        ctaButtonsContainer.showHandle = true
        cv.abovescrollView = ctaButtonsContainer
        cv.pinOverscrollToBottom = true
        cv.stickAbovescrollViewToBottom = true
        cv.abovescrollViewAboveCells = true
        ctaButtonsContainer.delegate = self
    }

    func updateLogo(_ viewModel: SignersViewModel) {
        // Adding first wallet
        if !logoAnimView.isHidden && !viewModel.isEmpty {
            UIView.animate(
                withDuration: 0.6,
                delay: 0.3, animations: {
                    self.logoAnimView.alpha = 0
                    self.openBetaView.alpha = 0
                },
                completion: { _ in
                    self.logoAnimView.isHidden = true
                    self.openBetaView.isHidden = true
                }
            )
        // Removing last wallet
        } else if logoAnimView.isHidden && viewModel.isEmpty {
            animateIntro(false)
        }
    }

    func selectedIdxPaths() -> [IndexPath] {
        guard let viewModel = viewModel, !viewModel.items.isEmpty else { return [] }
        return viewModel.selectedIdxs.map { IndexPath(item: $0.intValue, section: 0) }
    }

    func layoutAboveScrollView() {
        let btnCnt = viewModel?.buttons.count ?? 0
        let size = ctaButtonsContainer.intrinsicContentSize(for: btnCnt)
        let  bottomInset = view.safeAreaInsets.bottom
        cv.abovescrollView?.bounds.size = .init(
            width: view.bounds.width,
            height: size.height + bottomInset
        )

    }
}

// MARK: - Into animations

extension SignersViewController {

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
        animateOpenBeta()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.logoAnimView.alpha = 1
            self?.logoAnimView.animate()
        }
    }

    func animateButtonsIntro() {
        let height = ctaButtonsContainer.bounds.height
        let transform = CATransform3DMakeTranslation(0, height, 0)
        UIView.performWithoutAnimation {
            ctaButtonsContainer.layer.transform = transform
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) { [weak self] in
            self?.ctaButtonsContainer.isHidden = false
            UIView.springAnimate {
                self?.ctaButtonsContainer.layer.transform = CATransform3DIdentity
            }
        }
    }

    func animateOpenBeta() {
        let views = openBetaView.arrangedSubviews.map { $0 as? UIImageView }
        for (idx, view) in views.compactMap({$0}).enumerated() {
            view.alpha = 0.2
            animateLetter(view, delay: (idx > 4 ? 0.1 * Double(idx) : 0) + 3)
        }
        openBetaView.isHidden = false
        UIView.animate(withDuration: 1) { self.openBetaView.alpha = 1 }
    }

    func animateLetter(_ view: UIView, delay: TimeInterval) {
        UIView.springAnimate(
            0.7,
            delay: delay,
            damping: 0.01,
            velocity: 0.8,
            animations: { view.alpha = 1 }
        )
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension SignersViewController: TargetViewTransitionDatasource {

    func targetView() -> UIView? {
        if let input = transitionTargetView as? SignersViewModel.TransitionTargetViewKeyStoreItemAt {
            return cv.cellForItem(at: IndexPath(item: input.idx.int))
        }
        if let input = transitionTargetView as? SignersViewModel.TransitionTargetViewButtonAt {
            return ctaButtonsContainer.buttonViewAt(idx: input.idx.int)
        }
        return nil
    }
}
