// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore


class SettingsViewController: UICollectionViewController,
                              UICollectionViewDelegateFlowLayout {
    
    var presenter: SettingsPresenter!

    private var prevSize: CGSize = .zero
    private var cellSize: CGSize = .zero
    private var viewModel: CollectionViewModel.Screen?
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

    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme(Theme)
        cv?.collectionViewLayout.invalidateLayout()
    }

    // MARK: - SettingsView
    
    func update(with viewModel: CollectionViewModel.Screen) {
        self.viewModel = viewModel
        self.title = viewModel.id
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
        viewModel?.sections[section].items.count ?? 0
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeue(LabelCell.self, for: indexPath)
        return cell.update(with: viewModel(at: indexPath))
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return collectionView.dequeue(
                SectionHeaderView.self,
                for: indexPath,
                kind: .header
            ).update(with: viewModel?.sections[indexPath.section])
        case UICollectionView.elementKindSectionFooter:
            return collectionView.dequeue(
                SectionFooterView.self,
                for: indexPath,
                kind: .footer
            ).update(with: viewModel?.sections[indexPath.section])
        default:
            fatalError("Failed to handle \(kind) \(indexPath)")
        }
    }
    
    func updateTheme() {
        Theme = loadThemeFromSettings()
//        AppDelegate.refreshTraits()
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

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        String.estimateSize(
            viewModel?.sections[section].header,
            font: Theme.font.sectionHeader,
            maxWidth: cellSize.width,
            extraHeight: Theme.padding.twice,
            minHeight: Theme.padding
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        String.estimateSize(
            viewModel?.sections[section].footer,
            font: Theme.font.sectionFooter,
            maxWidth: cellSize.width,
            extraHeight: Theme.padding
        )
    }

    // MARK: - UICollectionViewDelegate
    
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        presenter.handleEvent(
            .Select(
                section: indexPath.section.int32,
                item: indexPath.item.int32
            )
        )
    }
    
}

// MARK: - Configure UI

private extension SettingsViewController {
    
    func configureUI() {
        title = Localized("Settings")
        configureOverscrollView()
        applyTheme(Theme)
        cv?.contentInset.bottom = Theme.padding * 3
    }

    func applyTheme(_ theme: ThemeProtocol) {
        cv?.separatorInsets = .with(left: theme.padding)
        cv?.sectionBackgroundColor = Theme.color.bgPrimary
        cv?.sectionBorderColor = Theme.color.collectionSectionStroke
        cv?.separatorColor = Theme.color.collectionSeparator
        (cv?.overscrollView?.subviews.first as? UILabel)?.textColor = Theme.color.textPrimary
    }

    func recomputeSizeIfNeeded() {
        guard prevSize.width != view.bounds.size.width else { return }
        prevSize = view.bounds.size
        cellSize = .init(
            width: view.bounds.size.width - Theme.padding * 2,
            height: Theme.cellHeight
        )
    }
    
    func configureOverscrollView() {
        cv?.overscrollView = UIImageView(imgName: "overscroll_anon")
        let version = UILabel(
            Theme.font.footnote,
            color: Theme.color.textPrimary,
            text: Bundle.main.version() + "v #" + Bundle.main.build()
        )
        let center = cv?.overscrollView?.bounds.midXY ?? .zero
        cv?.overscrollView?.addSubview(version)
        version.center = .init(x: center.x - 1.5, y: center.x + 31)
    }

    func viewModel(at idxPath: IndexPath) -> CellViewModel? {
        viewModel?.sections[idxPath.section].items[idxPath.item].cellViewModel
    }

}
