// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore


class SettingsViewController: CollectionViewController {
    
    var presenter: SettingsPresenter!

    override func configureUI() {
        title = Localized("Settings")
        super.configureUI()
        configureOverscrollView()
        presenter.present()
        cv.stickAbovescrollViewToBottom = false
        cv.abovescrollViewAboveCells = false
        cv.pinOverscrollToBottom = false
    }

    // MARK: - SettingView

    override func present() {
        presenter.present()
    }

    override func update(with viewModel: CollectionViewModel.Screen) {
        super.update(with: viewModel)
        title = viewModel.id
    }

    func updateThemeAndRefreshTraits() {
        Theme = loadThemeFromSettings()
        // Once all views were moved to traits based theme
        // AppDelegate.refreshTraits()
    }

    func refreshTraits() {
        // NOTE: Temporary hack. Once we have refreshTraits for iOS 17 and
        // this hack for prior
        let navVc = tabBarController?.viewControllers?[safe: 2]?.asNavVc
        let vc = navVc?.viewControllers.first as? NFTsDashboardViewController
        vc?.traitCollectionDidChange(nil)
        // AppDelegate.refreshTraits()
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
        guard let viewModel = self.viewModel(at: indexPath) else {
            fatalError("[SettingsView] ViewModel wrong idxPath:  \(indexPath)")
        }
        switch viewModel {
        case let vm as CellViewModel.Label:
            return cv.dequeue(LabelCell.self, for: indexPath)
                .update(with: vm)
        case let vm as CellViewModel.Switch:
            return cv.dequeue(SwitchCollectionViewCell.self, for: indexPath)
                .update(with: vm) { [weak self] v in
                    self?.handleSelect(indexPath)
                }
        default:
            fatalError("[SettingsView] ViewModel wrong idxPath:  \(indexPath)")
        }
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

    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return cellSize
    }

    // MARK: - UICollectionViewDelegate
    
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        handleSelect(indexPath)
    }

    // MARK: - Actions

    private func handleSelect(_ idxPath: IndexPath) {
        presenter.handleEvent(
            .Select(section: idxPath.section.int32, item: idxPath.item.int32)
        )
    }
}

// MARK: - Configure UI

private extension SettingsViewController {

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
}
