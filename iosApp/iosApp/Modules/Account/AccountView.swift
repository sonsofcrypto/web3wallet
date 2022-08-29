// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import WebKit

protocol AccountView: AnyObject {
    func update(with viewModel: AccountViewModel)
}

final class AccountViewController: BaseViewController {
    
    var presenter: AccountPresenter!
    
    private var viewModel: AccountViewModel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
}

extension AccountViewController: AccountView {
    
    func update(with viewModel: AccountViewModel) {
        
        self.viewModel = viewModel
        title = viewModel.currencyName
        collectionView.reloadData()
        refreshControl.endRefreshing()
        
        let btnLabel = (navigationItem.rightBarButtonItem?.customView as? UILabel)
        btnLabel?.text = viewModel.header.pct
        btnLabel?.textColor = viewModel.header.pctUp
        ? Theme.colour.priceUp
        : Theme.colour.priceDown
    }
}

extension AccountViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.all().count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        Section(rawValue: section)?.cellCount(viewModel) ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .header:
            let cell = collectionView.dequeue(AccountHeaderCell.self, for: indexPath)
            cell.update(with: viewModel.header, handler: makeHeaderHandler())
            return cell
        case .address:
            let cell = collectionView.dequeue(AccountAddressCell.self, for: indexPath)
            cell.update(with: viewModel.address)
            return cell
        case .chart:
            let cell = collectionView.dequeue(AccountChartCell.self, for: indexPath)
            cell.update(with: viewModel.candles)
            return cell
        case .marketInfo:
            if indexPath.item == 1 {
                let cell = collectionView.dequeue(AccountBonusCell.self, for: indexPath)
                cell.titleLabel.text = viewModel.bonusAction?.title ?? ""
                return cell
            }
            let cell = collectionView.dequeue(AccountMarketInfoCell.self, for: indexPath)
            cell.update(with: viewModel.marketInfo)
            return cell
        case .transactions:
            let transaction = viewModel.transactions[indexPath.item]
            let cell: CollectionViewCell
            switch transaction {
            case .empty:
                let _cell = collectionView.dequeue(AccountTransactionEmptyCell.self, for: indexPath)
                _cell.update(with: transaction)
                cell = _cell
            case .loading:
                let _cell = collectionView.dequeue(AccountTransactionLoadingCell.self, for: indexPath)
                _cell.update(with: transaction)
                cell = _cell
            case .data:
                let _cell = collectionView.dequeue(AccountTransactionCell.self, for: indexPath)
                _cell.update(with: transaction)
                cell = _cell
            }
            cell.separatorViewLeadingPadding = Theme.constant.padding
            cell.separatorViewTrailingPadding = Theme.constant.padding
            if viewModel.transactions.count == 1 {
                cell.update(for: .single)
                cell.bottomSeparatorView.isHidden = true
            } else if indexPath.item == 0 {
                cell.update(for: .top)
                cell.bottomSeparatorView.isHidden = false
            } else if indexPath.item == (viewModel.transactions.count) - 1 {
                cell.update(for: .bottom)
                cell.bottomSeparatorView.isHidden = true
            } else {
                cell.update(for: .middle)
                cell.bottomSeparatorView.isHidden = false
            }
            return cell
        }
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
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

extension AccountViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = Section(rawValue: indexPath.section) else {
            return .zero
        }
        
        let width = view.bounds.width - Theme.constant.padding * 2
        
        switch section {
        case .header:
            return CGSize(width: width, height: Constant.headerHeight)
        case .address:
            return CGSize(width: width, height: Constant.addressHeight)
        case .chart:
            return CGSize(width: width, height: Constant.chartHeight)
        case .marketInfo:
            return CGSize(width: width, height: Constant.marketInfoHeight)
        case .transactions:
            switch viewModel.transactions[indexPath.item] {
            case .empty:
                return CGSize(width: width, height: Constant.transactionsHeight * 0.75)
            case .loading:
                return CGSize(width: width, height: Constant.transactionsHeight * 1.5)
            case .data:
                return CGSize(width: width, height: Constant.transactionsHeight)
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard let section = Section(rawValue: section), section == .transactions else {
            return .zero
        }
        return CGSize(
            width: view.bounds.width - Theme.constant.padding * 2,
            height: Constant.sectionHeaderHeight
        )
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        guard let section = Section(rawValue: section), section == .marketInfo else {
            return 0
        }
        return Theme.constant.padding
    }
}

extension AccountViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        
        if section == .address {
            UIPasteboard.general.string = viewModel.address.address
            return view.presentToastAlert(with: Localized("account.action.copy.toast"))
        }
        
        if section == .transactions {
            guard let txHash = viewModel.transactions[indexPath.item].data?.txHash else { return }
            return EtherscanHelper().view(txHash: txHash, presentingIn: self)
        }
        
        if section == .marketInfo && indexPath.item == 1 {
            // TODO: Get presenter to present bonus action view
            let webViewController = WebViewController()
            let url = Bundle.main.url(forResource: "cult_manifesto", withExtension: ".pdf")!
            let navVc = NavigationController(rootViewController: webViewController)
            webViewController.title = "Manifesto"
            webViewController.webView.loadFileURL(url, allowingReadAccessTo: url)
            present(navVc, animated: true)
        }
    }
}

extension AccountViewController {
    
    enum Section: Int {
        case header = 0
        case address
        case chart
        case marketInfo
        case transactions
        
        func cellCount(_ viewModel: AccountViewModel) -> Int {
            
            switch self {
            case .marketInfo:
                return viewModel.bonusAction != nil ? 2 : 1
            case .transactions:
                return viewModel.transactions.count
            default:
                return 1
            }
        }
        
        static func all() -> [Section] {
            [.header, .address, .chart, marketInfo, transactions]
        }
    }
}

private extension AccountViewController {
    
    func configureUI() {
        
        title = Localized("wallets")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.glowLabel()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: "chevron.left".assetImage,
            style: .plain,
            target: self,
            action: #selector(dismissAction)
        )
        
        var insets = collectionView.contentInset
        insets.bottom += Theme.constant.padding
        collectionView.contentInset = insets
        collectionView.refreshControl = refreshControl
        
        refreshControl.tintColor = Theme.colour.activityIndicator
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
    }
    
    @objc func dismissAction() {
        
        dismiss(animated: true)
    }
    
    @objc func didPullToRefresh(_ sender: Any) {

        presenter.handle(.pullDownToRefresh)
    }
}

private extension AccountViewController {
    
    func makeHeaderHandler() -> AccountHeaderCell.Handler {
        
        .init(
            onReceiveTapped: makeOnReceiveTapped(),
            onSendTapped: makeOnSendTapped(),
            onSwapTapped: makeOnSwapTapped(),
            onMoreTapped: makeOnMoreTapped()
        )
    }
    
    func makeOnReceiveTapped() -> () -> Void {
        {
            [weak self] in self?.presenter.handle(.receive)
        }
    }
    
    func makeOnSendTapped() -> () -> Void {
        {
            [weak self] in self?.presenter.handle(.send)
        }
    }
    
    func makeOnSwapTapped() -> () -> Void {
        {
            [weak self] in self?.presenter.handle(.swap)
        }
    }
    
    func makeOnMoreTapped() -> () -> Void {
        {
            [weak self] in self?.presenter.handle(.more)
        }
    }
}

extension AccountViewController {
    
    enum Constant {
        static let headerHeight: CGFloat = 144
        static let addressHeight: CGFloat = 71
        static let chartHeight: CGFloat = 162
        static let marketInfoHeight: CGFloat = 71
        static let transactionsHeight: CGFloat = 72
        static let sectionHeaderHeight: CGFloat = 24
    }
}
