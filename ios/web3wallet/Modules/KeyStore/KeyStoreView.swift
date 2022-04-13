// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol KeyStoreView: AnyObject {

    func update(with viewModel: KeyStoreViewModel)
}

class KeyStoreViewController: UIViewController {

    var presenter: KeyStorePresenter!

    private var viewModel: KeyStoreViewModel?
    private var prevViewSize: CGSize = .zero
    private var firstAppear: Bool = true

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var logoContainer: UIView!
    @IBOutlet weak var buttonsCollectionView: UICollectionView!
    @IBOutlet weak var buttonBackgroundView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        configureUI()
        presenter?.present()
        prevViewSize = view.bounds.size
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if view.bounds.size != prevViewSize {
            collectionView.collectionViewLayout.invalidateLayout()
            prevViewSize = view.bounds.size
            configureInsets()
            layoutButtonsBackground()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateButtonsIntro()
        collectionView.indexPathsForSelectedItems?.forEach {
            collectionView.deselectItem(at: $0, animated: true)
        }
    }
}

// MARK: - KeyStoreView

extension KeyStoreViewController: KeyStoreView {

    func update(with viewModel: KeyStoreViewModel) {
        let isExpanded = self.viewModel?.buttons.isExpanded
        let btnsNeedsUpdate = isExpanded != viewModel.buttons.isExpanded
        self.viewModel = viewModel
        btnsNeedsUpdate ? updateButtonsView() : ()

        collectionView.reloadData()
        logoContainer.isHidden = !viewModel.isEmpty

        if let idx = viewModel.selectedIdx, !viewModel.items.isEmpty {
            collectionView.deselectAllExcept(
                IndexPath(item: idx, section: 0),
                animated: true
            )
        }
    }
}

// MARK: - UICollectionViewDataSource

extension KeyStoreViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == buttonsCollectionView {
            return viewModel?.buttons.buttons.count ?? 0
        }
        return viewModel?.items.count ?? 0
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == buttonsCollectionView {
            let button = viewModel?.buttons.buttons[indexPath.item]
            return collectionView.dequeue(ButtonsSheetViewCell.self, for: indexPath)
                    .update(with: button)
        }

        let cell = collectionView.dequeue(KeyStoreCell.self, for: indexPath)
        cell.titleLabel.text = viewModel?.items[indexPath.item].title
        return cell
    }
}

extension KeyStoreViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == buttonsCollectionView {
            presenter.handle(.didSelectButtonAt(idx: indexPath.item))
            return
        }
        presenter.handle(.didSelectKeyStoreItemtAt(idx: indexPath.item))
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == buttonsCollectionView else {
            return
        }

        layoutButtonsBackground()

        guard scrollView.isDragging else {
            return
        }

        presenter.handle(
            .didChangeButtonsState(
                open: buttonsCollectionView.visibleCells.count > 4
            )
        )
    }
}

extension KeyStoreViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: view.bounds.width - Global.padding * 2,
            height: Global.cellHeight
        )
    }
}

// MARK: - Configure UI

extension KeyStoreViewController {
    
    func configureUI() {
        title = Localized("wallets")
        configureInsets()
        buttonBackgroundView.layer.cornerRadius = Global.cornerRadius * 2
        buttonBackgroundView.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMinXMinYCorner
        ]
        (view as? GradientView)?.colors = [
            Theme.current.background,
            Theme.current.backgroundDark
        ]
    }

    func configureInsets() {
        let inset = view.bounds.height
            - Global.cellHeight * 4
            - Global.padding * 6
            + 2
        print("=== configuring insets", view.bounds, inset)
        buttonsCollectionView.contentInset.top = inset
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
            y: top.y - Global.padding * 2,
            width: view.bounds.width,
            height: view.bounds.height - top.y + Global.padding * 2
        )

        if let cv = buttonsCollectionView {
            let alpha = (cv.contentInset.top + cv.contentOffset.y) / 100
            buttonBackgroundView.alpha = min(1, max(0, alpha))
        }
    }

    func updateButtonsView() {
        buttonsCollectionView.reloadData()
        let expanded = viewModel?.buttons.isExpanded ?? false

        guard let cv = buttonsCollectionView,
              !buttonsCollectionView.isDragging else {
            return
        }

        if expanded {
            let y = cv.bounds.height - cv.contentSize.height - Global.padding * 2
            buttonsCollectionView.setContentOffset(
                CGPoint(x: 0, y: -y),
                animated: true
            )
        } else {
            buttonsCollectionView.setContentOffset(
                CGPoint(x: 0, y: -buttonsCollectionView.contentInset.top),
                animated: true
            )
        }
    }

    func animateButtonsIntro() {
        guard firstAppear && viewModel?.isEmpty ?? true else {
            return
        }

        firstAppear = false

        buttonsCollectionView.setContentOffset(
            CGPoint(x: 0, y: -view.bounds.height),
            animated: false
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.updateButtonsView()
        }
    }
}
