// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol TokenSwapView: AnyObject {

    func update(with viewModel: TokenSwapViewModel)
    func presentFeePicker(with fees: [FeesPickerViewModel])
    //func presentReviewSwap(with fees: [FeesPickerViewModel])
    func loading()
    func dismissKeyboard()
}

final class TokenSwapViewController: BaseViewController {

    var presenter: TokenSwapPresenter!

    private weak var segmentControl: SegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var feesPickerView: FeesPickerView!
    
    private var viewModel: TokenSwapViewModel?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter?.present()
    }
}

extension TokenSwapViewController: TokenSwapView {

    func update(with viewModel: TokenSwapViewModel) {

        self.viewModel = viewModel
        
        if collectionView.visibleCells.isEmpty {
            
            collectionView.reloadData()
        } else {
            
            updateCells()
        }
    }
    
    func presentFeePicker(with fees: [FeesPickerViewModel]) {
        
        dismissKeyboard()
                
        let cell = collectionView.visibleCells.first { $0 is TokenSwapMarketCollectionViewCell } as! TokenSwapMarketCollectionViewCell

        let fromFrame = feesPickerView.convert(
            cell.networkFeeView.networkFeeButton.bounds,
            from: cell.networkFeeView.networkFeeButton
        )
        feesPickerView.present(
            with: fees,
            onFeeSelected: makeOnFeeSelected(),
            at: .init(
                x: Theme.constant.padding,
                y: fromFrame.midY
            )
        )
    }
    
    func loading() {
        
        collectionView.visibleCells.forEach {
            
            switch $0 {
                
            case let cell as TokenSwapMarketCollectionViewCell:
                cell.showLoading()
                
            default:
                break
            }
        }
    }
    
    @objc func dismissKeyboard() {
        
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
}

extension TokenSwapViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        viewModel?.items.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let item = viewModel?.items[indexPath.row] else { fatalError() }
        
        switch item {
            
        case let .swap(swap):
            
            let cell = collectionView.dequeue(TokenSwapMarketCollectionViewCell.self, for: indexPath)
            cell.update(with: swap, handler: makeTokenSwapHandler())
            return cell
            
        case .limit:

            let cell = collectionView.dequeue(TokenSwapLimitCollectionViewCell.self, for: indexPath)
            return cell

        }
    }
}

extension TokenSwapViewController: UICollectionViewDelegate {
    
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

private extension TokenSwapViewController {
    
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
        
        let segmentControl = makeSegmentedControl()
        navigationItem.titleView = segmentControl
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.isPagingEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        collectionView.addGestureRecognizer(tapGesture)
        
        collectionView.setCollectionViewLayout(
            makeCompositionalLayout(),
            animated: false
        )
        
        feesPickerView.isHidden = true
    }
    
    func makeOnFeeSelected() -> ((FeesPickerViewModel) -> Void) {
        
        {
            [weak self] item in
            guard let self = self else { return }
            self.presenter.handle(.feeChanged(to: item.id))
        }
    }
    
    @objc func segmentControlChanged(_ sender: SegmentedControl) {
        
        if sender.selectedSegmentIndex == 1 {
            
            sender.selectedSegmentIndex = 0
            presenter.handle(.providerTapped)
        }        
    }
    
    @objc func navBarLeftActionTapped() {
        
        presenter.handle(.dismiss)
    }
    
    func makeSegmentedControl() -> SegmentedControl {
        
        let segmentControl = SegmentedControl()
        segmentControl.insertSegment(
            withTitle: Localized("tokenSwap.segment.swap"),
            at: 0,
            animated: false
        )
        segmentControl.insertSegment(
            withTitle: Localized("tokenSwap.segment.limit"),
            at: 1,
            animated: false
        )
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentControlChanged(_:)), for: .valueChanged)

        self.segmentControl = segmentControl
        
        return segmentControl
    }
}

private extension TokenSwapViewController {
    
    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            
            guard let self = self else { return nil }
            
            switch sectionIndex {
                
            case 0:
                return self.makeCollectionLayoutSection(
                    sectionIndex: sectionIndex
                )
                
            default:
                fatalError()
            }
        }
    }
    
    func makeCollectionLayoutSection(
        sectionIndex: Int
    ) -> NSCollectionLayoutSection {
        
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
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
        
        // Section
        let sectionInset: CGFloat = Theme.constant.padding
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = .init(
            top: sectionInset * 0.75,
            leading: sectionInset.half,
            bottom: 0,
            trailing: sectionInset.half
        )
        section.orthogonalScrollingBehavior = .groupPaging
        section.visibleItemsInvalidationHandler = {
            // [weak self] visibleItems, point, environment in
            [weak self] (_, _, _) in
            guard let self = self else { return }
            self.dismissKeyboard()
        }
                        
        return section
    }
}

private extension TokenSwapViewController {
    
    func updateCells() {
        
        collectionView.visibleCells.forEach {
            
            switch $0 {
                
            case let tokenCell as TokenSwapMarketCollectionViewCell:
                
                guard let swap = viewModel?.items.swap else { return }
                tokenCell.update(with: swap, handler: makeTokenSwapHandler())
                
            case _ as TokenSwapLimitCollectionViewCell:
                
                break

            default:
                
                fatalError()
            }
        }
    }
}

private extension TokenSwapViewController {
    
    func makeTokenSwapHandler() -> TokenSwapMarketCollectionViewCell.Handler {
        
        .init(
            onTokenFromTapped: makeOnTapped(.tokenFromTapped),
            onTokenFromAmountChanged: makeOnTokenFromAmountChanged(),
            onTokenToTapped: makeOnTapped(.tokenToTapped),
            onTokenToAmountChanged: makeOnTokenToAmountChanged(),
            onSwapFlip: makeOnTapped(.swapFlip),
            onProviderTapped: makeOnTapped(.providerTapped),
            onSlippageTapped: makeOnTapped(.slippageTapped),
            onNetworkFeesTapped: makeOnTapped(.feeTapped),
            onApproveCTATapped: makeOnTapped(.approve),
            onCTATapped: makeOnTapped(.review)
        )
    }
    
    func makeOnTokenFromAmountChanged() -> (BigInt) -> Void {
        
        {
            [weak self] amount in
            guard let self = self else { return }
            self.presenter.handle(.tokenFromChanged(to: amount))
        }
    }
    
    func makeOnTokenToAmountChanged() -> (BigInt) -> Void {
        
        {
            [weak self] amount in
            guard let self = self else { return }
            self.presenter.handle(.tokenToChanged(to: amount))
        }
    }
    
    func makeOnTapped(_ event: TokenSwapPresenterEvent) -> () -> Void {
        
        {
            [weak self] in
            guard let self = self else { return }
            self.presenter.handle(event)
        }
    }
}
