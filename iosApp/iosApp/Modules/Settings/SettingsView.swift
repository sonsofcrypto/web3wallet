// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol SettingsView: AnyObject {
    func update(with viewModel: SettingsViewModel)
}

class SettingsViewController: UICollectionViewController,
    UICollectionViewDelegateFlowLayout, SettingsView {
    
    var presenter: SettingsPresenter!

    private var prevSize: CGSize = .zero
    private var cellSize: CGSize = .zero
    private var viewModel: SettingsViewModel?
    private var cv: CollectionView? { collectionView as? CollectionView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        recomputeSizeIfNeeded()
    }
    
    // MARK: - SettingsView
    
    func update(with viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
    }

    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.sections.count ?? 0
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel?.sections[section].items.count ?? 0
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeue(LabelCell.self, for: indexPath)
        return cell.update(
            with: viewModel?.sections[indexPath.section].items[indexPath.item]
        )
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeue(
                SectionHeaderView.self,
                for: indexPath,
                kind: .header
            )
            header.label.text = "Section \(indexPath.section)"
            return header
        default:
            fatalError("Failed to handle \(kind) \(indexPath)")
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        recomputeSizeIfNeeded()
        return cellSize
    }
    
    // MARK: - UICollectionViewDelegate
    
}

// MARK: - Configure UI

private extension SettingsViewController {
    
    func configureUI() {
        title = Localized("Settings")
        configureOverscrollView()
    }
    
    func recomputeSizeIfNeeded() {
        guard prevSize.width != view.bounds.size.width else { return }
        prevSize = view.bounds.size
        cellSize = .init(
            width: view.bounds.size.width - Theme.padding * 2,
            height: Theme.cellHeightSmall
        )
    }
    
    func configureOverscrollView() {
        cv?.overscrollView = UIImageView(imgName: "overscroll_anon")
        let version = UILabel(with: .footnote)
        version.text = Bundle.main.version() + "v #" + Bundle.main.build()
        cv?.overscrollView?.addSubview(version)
        version.sizeToFit()
        version.center = cv?.overscrollView?.bounds.midXY ?? .zero
        version.center.x -= 1.5
        version.center.y += 31
    }
}
