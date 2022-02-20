// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DashboardView: AnyObject {

    func update(with viewModel: DashboardViewModel)
}

class DashboardViewController: UIViewController {

    var presenter: DashboardPresenter!

    private var viewModel: DashboardViewModel?
    private var walletCellSize: CGSize = .zero
    private var nftsCellSize: CGSize = .zero
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let length = (view.bounds.width - Global.padding * 2 - Constant.spacing) / 2
        walletCellSize = CGSize(width: length, height: length)
        nftsCellSize = CGSize(
            width: view.bounds.width - Global.padding * 2,
            height: length)
    }

    // MARK: - Actions

    @IBAction func receiveAction(_ sender: Any) {
        presenter.handle(.receiveAction)
    }

    @IBAction func sendAction(_ sender: Any) {
        presenter.handle(.sendAction)
    }

    @IBAction func tradeAction(_ sender: Any) {
        presenter.handle(.tradeAction)
    }

    @IBAction func walletConnectionSettingsAction(_ sender: Any) {
        presenter.handle(.walletConnectionSettingsAction)
    }

}

// MARK: - WalletsView

extension DashboardViewController: DashboardView {

    func update(with viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
        let pctLabel = navigationItem.rightBarButtonItem?.customView as? UILabel
        pctLabel?.text = viewModel.header.pct
        pctLabel?.textColor = viewModel.header.pctUp
            ? Theme.current.green
            : Theme.current.red
    }
}

// MARK: - UICollectionViewDataSource

extension DashboardViewController: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.sections.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = viewModel?.sections[section] else {
            return 0
        }
        return section.wallets.count + (section.nfts.count > 0 ? 1 : 0)
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = viewModel?.sections[indexPath.section] else {
            fatalError("No viewModel for \(indexPath) \(collectionView)")
        }

        if indexPath.item >= section.wallets.count {
            let cell = collectionView.dequeue(DashboardNFTsCell.self, for: indexPath)
            cell.update(with: section.nfts)
            return cell
        } else {
            let cell = collectionView.dequeue(DashboardWalletCell.self, for: indexPath)
            cell.update(with: section.wallets[indexPath.item])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            switch indexPath.section {
            case 0:
                let supplementary = collectionView.dequeue(
                    DashboardHeaderView.self,
                    for: indexPath,
                    kind: kind
                )
                supplementary.update(with: viewModel?.header)
                addActions(for: supplementary)
                return supplementary
            default:
                let supplementary = collectionView.dequeue(
                    DashboardSectionHeaderView.self,
                    for: indexPath,
                    kind: kind
                )
                supplementary.update(with: viewModel?.sections[indexPath.section])
                return supplementary
            }
        }

        fatalError("Unexpected supplementary idxPath: \(indexPath) \(kind)")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DashboardViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item >= viewModel?.sections[indexPath.section].wallets.count ?? 0 {
            return nftsCellSize
        }

        return walletCellSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(
            width: view.bounds.width - Global.padding * 2,
            height: section == 0 ? Constant.headerHeight : Constant.sectionHeaderHeight
        )
    }
}

// MARK: - UICollectionViewDelegate

extension DashboardViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = viewModel?.sections[indexPath.section]
        if indexPath.item < section?.wallets.count ?? 0 {
            presenter.handle(.didSelectWallet(idx: indexPath.item))
        }
        // TODO: implement NFT selection
    }
}

// MARK: - Configure UI

extension DashboardViewController {
    
    func configureUI() {
        title = Localized("dashboard")
        (view as? GradientView)?.colors = [
            Theme.current.background,
            Theme.current.backgroundDark
        ]

        tabBarItem = UITabBarItem(
            title: Localized("dashboard.tab.title"),
            image: UIImage(named: "tab_icon_dashboard"),
            tag: 0
        )

        collectionView.register(
            DashboardSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(DashboardSectionHeaderView.self)"
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem.glowLabel()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "arrow_back"),
            style: .plain,
            target: self,
            action: #selector(walletConnectionSettingsAction(_:))
        )

    }
}

// MARK: - Utilities

private extension DashboardViewController {

    func addActions(for supplementary: DashboardHeaderView) {
        supplementary.receiveButton.addTarget(
            self,
            action: #selector(receiveAction(_:)),
            for: .touchUpInside
        )
        supplementary.sendButton.addTarget(
            self,
            action: #selector(sendAction(_:)),
            for: .touchUpInside
        )
        supplementary.tradeButton.addTarget(
            self,
            action: #selector(tradeAction(_:)),
            for: .touchUpInside
        )
    }
}

// MARK: - Constant

extension DashboardViewController {

    enum Constant {
        static let headerHeight: CGFloat = 211
        static let sectionHeaderHeight: CGFloat = 59
        static let spacing: CGFloat = 17
    }
}
