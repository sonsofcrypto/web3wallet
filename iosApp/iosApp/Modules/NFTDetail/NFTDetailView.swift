// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class NFTDetailViewController: UICollectionViewController, ButtonSheetContainerDelegate {

    var presenter: NFTDetailPresenter!

    private var viewModel: NFTDetailViewModel?
    private var ctaButtonsContainer: ButtonSheetContainer?
    private var cv: CollectionView! { (collectionView as! CollectionView) }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.present()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutAboveScrollView()
    }

    func update(with viewModel: NFTDetailViewModel) {
        self.viewModel = viewModel
        title = viewModel.title
        collectionView.reloadData()
    }

    func presentAlert(with viewModel: AlertViewModel) {
        let vc = AlertController(viewModel, handler: { _, _ in () })
        present(vc, animated: true)
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        1 + (viewModel?.infos.count ?? 0)
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cv = collectionView
        guard indexPath.item != 0 else {
            return cv.dequeue(NFTDetailImageCell.self, for: indexPath)
                .update(with: viewModel)
        }
        return cv.dequeue(NFTDetailPropertiesCell.self, for: indexPath)
            .update(with: viewModel?.infos[safe: indexPath.item - 1])
    }

    // MARK: - Actions

    func buttonSheetContainer(_ bsc: ButtonSheetContainer, didSelect idx: Int) {
        presenter.handleEvent(.Send())
    }

    @objc func dismissTapped() {
        presenter.handleEvent(NFTDetailPresenterEvent.Dismiss())
    }

    // MARK: - Config

    private func configureUI() {
        title = Localized("nfts")
        let showBack = (navigationController?.viewControllers.count ?? 0) > 1
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            sysImgName: showBack ? "chevron.left" : "xmark",
            target: self,
            action: #selector(dismissTapped)
        )
        cv.pinOverscrollToBottom = true
        cv.stickAbovescrollViewToBottom = true
        cv.abovescrollViewAboveCells = true
        cv.contentInset = .with(all: Theme.padding)
        setupCTAButtons()
    }

    private func setupCTAButtons() {
        ctaButtonsContainer = ButtonSheetContainer()
        cv.abovescrollView = ctaButtonsContainer
        ctaButtonsContainer?.delegate = self
        ctaButtonsContainer?.setButtons(
            [ButtonViewModel(title: Localized("send"), kind: .primary)],
            compactCount: 1
        )
        layoutAboveScrollView()

    }

    private func layoutAboveScrollView() {
        cv.contentInset.bottom = bottomInset()
        guard let ctaButtonsContainer = ctaButtonsContainer else { return }
        let size = ctaButtonsContainer.intrinsicContentSize(for: 1)
        cv.abovescrollView?.bounds.size = .init(
            width: view.bounds.width,
            height: size.height + cv.safeAreaInsets.bottom + Theme.padding
        )
        cv.contentInset.bottom = bottomInset()
    }

    func bottomInset() -> CGFloat {
        (ctaButtonsContainer?.intrinsicContentSize(for: 1).height ?? 0)
            + Theme.padding.twice
    }
}
