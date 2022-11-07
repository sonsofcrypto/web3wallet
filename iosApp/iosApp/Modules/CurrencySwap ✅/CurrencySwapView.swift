// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class CurrencySwapViewController: BaseViewController {
    private weak var segmentControl: SegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var feesPickerView: NetworkFeePickerView!

    var presenter: CurrencySwapPresenter!

    private var viewModel: CurrencySwapViewModel?
    private var firstAppear: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            firstAppear = false
            let cell = collectionView.cellForItem(at: IndexPath.zero)
            let swapCell = cell as? CurrencySwapMarketCollectionViewCell
            swapCell?.currencyFrom?.amountTextField.becomeFirstResponder()
        }
    }
}

extension CurrencySwapViewController: CurrencySwapView {

    func update(viewModel___________ viewModel: CurrencySwapViewModel) {
        self.viewModel = viewModel
        if collectionView.visibleCells.isEmpty { collectionView.reloadData() }
        else { updateCells() }
    }
    
    func presentNetworkFeePicker(networkFees: [NetworkFee]) {
        dismissKeyboard()
        let cell = collectionView.visibleCells.first {
            $0 is CurrencySwapMarketCollectionViewCell
        } as! CurrencySwapMarketCollectionViewCell
        let fromFrame = feesPickerView.convert(
            cell.networkFeeView.networkFeeButton.bounds,
            from: cell.networkFeeView.networkFeeButton
        )
        feesPickerView.present(
            with: networkFees,
            onFeeSelected: makeOnFeeSelected(),
            at: .init(x: Theme.constant.padding, y: fromFrame.midY)
        )
    }
    
    func loading() {
        collectionView.visibleCells.forEach {
            switch $0 {
            case let cell as CurrencySwapMarketCollectionViewCell: cell.showLoading()
            default: break
            }
        }
    }
    
    @objc func dismissKeyboard() {
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
}

extension CurrencySwapViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.items.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let item = viewModel?.items[indexPath.row] else { fatalError() }
        if let input = item as? CurrencySwapViewModel.ItemSwap {
            let cell = collectionView.dequeue(CurrencySwapMarketCollectionViewCell.self, for: indexPath)
            cell.update(with: input.swap, handler: currencySwapHandler())
            return cell
        }
        fatalError("Item not handled")
//        if let input = item as? CurrencySwapViewModel.ItemLimit {
//            return collectionView.dequeue(CurrencySwapLimitCollectionViewCell.self, for: indexPath)
//        }
    }
}

extension CurrencySwapViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        segmentControl.selectedSegmentIndex = indexPath.row == 0 ? 1 : 0
    }
}

private extension CurrencySwapViewController {
    
    func configureUI() {
        if (navigationController?.viewControllers.count ?? 0) > 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: "chevron.left".assetImage,
                style: .plain,
                target: self,
                action: #selector(navBarLeftActionTapped)
            )
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: .init(systemName: "xmark"),
                style: .plain,
                target: self,
                action: #selector(navBarLeftActionTapped)
            )
        }
        navigationItem.titleView = _segmentedControl()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        collectionView.addGestureRecognizer(tapGesture)
        collectionView.setCollectionViewLayout(
            compositionalLayout(),
            animated: false
        )
        feesPickerView.isHidden = true
    }
    
    func makeOnFeeSelected() -> ((NetworkFee) -> Void) {
        { [weak self] item in self?.onTapped(CurrencySwapPresenterEvent.NetworkFeeChanged(value: item))() }
    }
    
    @objc func segmentControlChanged(_ sender: SegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            sender.selectedSegmentIndex = 0
            onTapped(CurrencySwapPresenterEvent.ProviderTapped())()
        }
    }
    
    @objc func navBarLeftActionTapped() { onTapped(CurrencySwapPresenterEvent.Dismiss())() }
    
    func _segmentedControl() -> SegmentedControl {
        let segmentControl = SegmentedControl()
        segmentControl.insertSegment(
            withTitle: Localized("currencySwap.segment.swap"),
            at: 0,
            animated: false
        )
        segmentControl.insertSegment(
            withTitle: Localized("currencySwap.segment.limit"),
            at: 1,
            animated: false
        )
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentControlChanged(_:)), for: .valueChanged)
        self.segmentControl = segmentControl
        return segmentControl
    }
}

private extension CurrencySwapViewController {
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return nil }
            switch sectionIndex {
            case 0:
                return self.makeCollectionLayoutSection(
                    sectionIndex: sectionIndex
                )
            default: fatalError()
            }
        }
    }
    
    func makeCollectionLayoutSection(
        sectionIndex: Int
    ) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let screenWidth: CGFloat = (view.bounds.width - Theme.constant.padding)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(screenWidth),
            heightDimension: .estimated(100)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        outerGroup.contentInsets = .init(
            top: 0,
            leading: 8,
            bottom: 0,
            trailing: 8
        )
        let sectionInset: CGFloat = Theme.constant.padding
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = .init(
            top: sectionInset.half,
            leading: sectionInset.half,
            bottom: 0,
            trailing: sectionInset.half
        )
        section.orthogonalScrollingBehavior = .groupPaging
        section.visibleItemsInvalidationHandler = {
            [weak self] (_, _, _) in self?.dismissKeyboard()
        }
        return section
    }
}

private extension CurrencySwapViewController {
    
    func updateCells() {
        collectionView.visibleCells.forEach {
            switch $0 {
            case let tokenCell as CurrencySwapMarketCollectionViewCell:
                guard let swap = viewModel?.items.swap else { return }
                tokenCell.update(with: swap, handler: currencySwapHandler())
            case _ as CurrencySwapLimitCollectionViewCell: break
            default: fatalError()
            }
        }
    }
}

private extension CurrencySwapViewController {
    
    func currencySwapHandler() -> CurrencySwapMarketCollectionViewCell.Handler {
        .init(
            onCurrencyFromTapped: onTapped(CurrencySwapPresenterEvent.CurrencyFromTapped()),
            onCurrencyFromAmountChanged: onCurrencyFromAmountChanged(),
            onCurrencyToTapped: onTapped(CurrencySwapPresenterEvent.CurrencyToTapped()),
            onCurrencyToAmountChanged: nil,
            onSwapFlip: onTapped(CurrencySwapPresenterEvent.SwapFlip()),
            onProviderTapped: onTapped(CurrencySwapPresenterEvent.ProviderTapped()),
            onSlippageTapped: onTapped(CurrencySwapPresenterEvent.SlippageTapped()),
            onNetworkFeesTapped: onTapped(CurrencySwapPresenterEvent.NetworkFeeTapped()),
            onApproveCTATapped: onTapped(CurrencySwapPresenterEvent.Approve()),
            onCTATapped: onTapped(CurrencySwapPresenterEvent.Review())
        )
    }
    
    func onCurrencyFromAmountChanged() -> (BigInt) -> Void {
        { [weak self] amount in self?.onTapped(CurrencySwapPresenterEvent.CurrencyFromChanged(value: amount))() }
    }
    
    func onTapped(_ event: CurrencySwapPresenterEvent) -> () -> Void {
        { [weak self] in self?.presenter.handle(event_______________: event) }
    }
}

extension Array where Element == CurrencySwapViewModel.Item {
    var swap: CurrencySwapViewModel.SwapData? {
        let item = first { $0 is CurrencySwapViewModel.ItemSwap }
        return (item as? CurrencySwapViewModel.ItemSwap)?.swap
    }
}
