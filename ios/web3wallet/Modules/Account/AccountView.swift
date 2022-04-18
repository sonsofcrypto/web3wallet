// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AccountView: AnyObject {

    func update(with viewModel: AccountViewModel)
}

class AccountViewController: UIViewController {

    var presenter: AccountPresenter!

    private var viewModel: AccountViewModel?
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    // MARK: - Actions

    @IBAction func receiveAction(_ sender: Any) {

    }

    @IBAction func sendAction(_ sender: Any) {

    }

    @IBAction func tradeAction(_ sender: Any) {

    }

    @IBAction func moreAction(_ sender: Any) {

    }

    @IBAction func dismissAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - WalletsView

extension AccountViewController: AccountView {

    func update(with viewModel: AccountViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
        title = viewModel.currencyName

        let btnLabel = (navigationItem.rightBarButtonItem?.customView as? UILabel)
        btnLabel?.text = viewModel.header.pct
        btnLabel?.textColor = viewModel.header.pctUp
            ? Theme.color.green
            : Theme.color.red
    }
}

// MARK: - UICollectionViewDataSource

extension AccountViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.all().count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Section(rawValue: section)?.cellCount(viewModel) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .header:
            let cell = collectionView.dequeue(AccountHeaderCell.self, for: indexPath)
            cell.update(with: viewModel?.header)
            return cell
        case .chart:
            let cell = collectionView.dequeue(AccountChartCell.self, for: indexPath)
            cell.update(with: viewModel?.candles)
            return cell
        case .marketInfo:
            let cell = collectionView.dequeue(AccountMarketInfoCell.self, for: indexPath)
            cell.update(with: viewModel?.marketInfo)
            return cell
        case .transactions:
            let cell = collectionView.dequeue(AccountTransactionCell.self, for: indexPath)
            cell.update(with: viewModel?.transactions[indexPath.item])
            if viewModel?.transactions.count == 1 {
                cell.update(for: .single)
            } else if indexPath.item == 0 {
                cell.update(for: .top)
            } else if indexPath.item == (viewModel?.transactions.count ?? 0) - 1 {
                cell.update(for: .bottom)
            } else {
                cell.update(for: .middle)
            }
            return cell
        }
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let supplementary = collectionView.dequeue(
                AccountSectionHeader.self,
                for: indexPath,
                kind: kind
            )
            supplementary.label.text = Localized("account.marketInfo.transactions")
            return supplementary
        }
        fatalError("Unexpected element \(kind) \(indexPath)")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AccountViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = Section(rawValue: indexPath.section) else {
            return .zero
        }

        let width = view.bounds.width - Global.padding * 2

        switch section {
        case .header:
            return CGSize(width: width, height: Constant.headerHeight)
        case .chart:
            return CGSize(width: width, height: Constant.chartHeight)
        case .marketInfo:
            return CGSize(width: width, height: Constant.marketInfoHeight)
        case .transactions:
            return CGSize(width: width, height: Constant.transactionsHeight)
        }

        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let section = Section(rawValue: section), section == .transactions else {
            return .zero
        }

        return CGSize(
            width: view.bounds.width - Global.padding * 2,
            height: Constant.sectionHeaderHeight
        )
    }
}

// MARK: - UICollectionViewDelegate

extension AccountViewController: UICollectionViewDelegate {
    
}


// MARK: - Section

extension AccountViewController {

    enum Section: Int {
        case header = 0
        case chart
        case marketInfo
        case transactions

        func cellCount(_ viewModel: AccountViewModel?) -> Int {
            guard let viewModel = viewModel else {
                return 0
            }

            switch self {
            case .transactions:
                return viewModel.transactions.count
            default:
                return 1
            }
        }

        static func all() -> [Section] {
            [.header, .chart, marketInfo, transactions]
        }
    }
}

// MARK: - Configure UI

extension AccountViewController {
    
    func configureUI() {
        title = Localized("wallets")
        (view as? GradientView)?.colors = [
            Theme.color.background,
            Theme.color.backgroundDark
        ]

        navigationItem.rightBarButtonItem = UIBarButtonItem.glowLabel()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "arrow_back"),
            style: .plain,
            target: self,
            action: #selector(dismissAction(_:))
        )
        navigationItem.leftBarButtonItem?.tintColor  = Theme.color.tint

        var insets = collectionView.contentInset
        insets.bottom += Global.padding
        collectionView.contentInset = insets
    }
}

// MARK: - Constant

extension AccountViewController {

    enum Constant {
        static let headerHeight: CGFloat = 172
        static let chartHeight: CGFloat = 162
        static let marketInfoHeight: CGFloat = 71
        static let transactionsHeight: CGFloat = 64
        static let sectionHeaderHeight: CGFloat = 24
    }
}
