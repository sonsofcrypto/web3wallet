// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol NFTSendView: AnyObject {
    func update(with viewModel: NFTSendViewModel)
    func presentFeePicker(with fees: [NetworkFee])
    func dismissKeyboard()
}

final class NFTSendViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var feesPickerView: NetworkFeePickerView!

    var presenter: NFTSendPresenter!

    private var viewModel: NFTSendViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
}

extension NFTSendViewController: NFTSendView {

    func update(with viewModel: NFTSendViewModel) {
        self.viewModel = viewModel
        title = viewModel.title
        if collectionView.visibleCells.isEmpty { collectionView.reloadData() }
        else { updateCells() }
    }
    
    func presentFeePicker(with fees: [NetworkFee]) {
        dismissKeyboard()
        let cell = collectionView.visibleCells.first { $0 is NFTSendCTACollectionViewCell } as! NFTSendCTACollectionViewCell
        let fromFrame = feesPickerView.convert(
            cell.networkFeeView.networkFeeButton.bounds,
            from: cell.networkFeeView.networkFeeButton
        )
        feesPickerView.present(
            with: fees,
            onFeeSelected: onFeeSelected(),
            at: .init(x: Theme.constant.padding, y: fromFrame.midY)
        )
    }
    
    @objc func dismissKeyboard() {
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
}

extension NFTSendViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let item = viewModel?.items[indexPath.section] else { fatalError() }
        switch item {
        case let .address(value):
            let cell = collectionView.dequeue(NFTSendToCollectionViewCell.self, for: indexPath)
            cell.update(with: value, handler: nftSendTokenHandler())
            return cell
        case let .nft(item):
            let cell = collectionView.dequeue(NFTSendImageCollectionViewCell.self, for: indexPath)
            cell.update(with: item)
            return cell
        case let .send(cta):
            let cell = collectionView.dequeue(NFTSendCTACollectionViewCell.self, for: indexPath)
            cell.update(with: cta, handler: nftSendCTAHandler())
            return cell
        }
    }
}

extension NFTSendViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { dismissKeyboard() }
}

private extension NFTSendViewController {
    
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
        collectionView.dataSource = self
        collectionView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        collectionView.addGestureRecognizer(tapGesture)
        collectionView.setCollectionViewLayout(compositionalLayout(), animated: false)
        feesPickerView.isHidden = true
    }
    
    func onFeeSelected() -> ((NetworkFee) -> Void) {
        { [weak self] item in self?.onTapped(.feeChanged(to: item))() }
    }
    
    @objc func navBarLeftActionTapped() {
        onTapped(.dismiss)()
    }
}

private extension NFTSendViewController {
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { index, environment in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(100)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(100)
            )
            let outerGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize, subitems: [item]
            )
            let sectionInset: CGFloat = Theme.constant.padding
            let section = NSCollectionLayoutSection(group: outerGroup)
            section.contentInsets = .init(
                top: index == 0 ? sectionInset : 0,
                leading: sectionInset,
                bottom: sectionInset,
                trailing: sectionInset
            )
            return section
        }
    }
    
    func updateCells() {
        collectionView.visibleCells.forEach {
            switch $0 {
            case let addressCell as NFTSendToCollectionViewCell:
                guard let address = viewModel?.items.address else { return }
                addressCell.update(with: address, handler: nftSendTokenHandler())
            case let imageCell as NFTSendImageCollectionViewCell:
                guard let nftItem = viewModel?.items.nft else { return }
                imageCell.update(with: nftItem)
            case let ctaCell as NFTSendCTACollectionViewCell:
                guard let cta = viewModel?.items.send else { return }
                ctaCell.update(with: cta, handler: nftSendCTAHandler())
            default: fatalError()
            }
        }
    }
}

private extension NFTSendViewController {
    
    func nftSendTokenHandler() -> NetworkAddressPickerView.Handler {
        .init(
            onAddressChanged: onAddressChanged(),
            onQRCodeScanTapped: onTapped(.qrCodeScan),
            onPasteTapped: onTapped(.pasteAddress),
            onSaveTapped: onTapped(.saveAddress)
        )
    }

    func onAddressChanged() -> (String) -> Void {
        { [weak self] value in self?.onTapped(.addressChanged(to: value))() }
    }
    
    func nftSendCTAHandler() -> NFTSendCTACollectionViewCell.Handler {
        .init(
            onNetworkFeesTapped: onTapped(.feeTapped),
            onCTATapped: onTapped(.review)
        )
    }
    
    func onTapped(_ event: NFTSendPresenterEvent) -> () -> Void {
        { [weak self] in self?.presenter.handle(event) }
    }
}
