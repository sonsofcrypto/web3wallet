// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol CurrencySendView: AnyObject {
    func update(with viewModel: CurrencySendViewModel)
    func presentFeePicker(with fees: [FeesPickerViewModel])
    func dismissKeyboard()
}

final class CurrencySendViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var feesPickerView: FeesPickerView!

    var presenter: CurrencySendPresenter!

    private var viewModel: CurrencySendViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }    
}

extension CurrencySendViewController: CurrencySendView {

    func update(with viewModel: CurrencySendViewModel) {
        self.viewModel = viewModel
        title = viewModel.title
        if collectionView.visibleCells.isEmpty { collectionView.reloadData() }
        else { updateCells() }
    }
    
    func presentFeePicker(with fees: [FeesPickerViewModel]) {
        dismissKeyboard()
        let cell = collectionView.visibleCells.first {
            $0 is CurrencySendCTACollectionViewCell
        } as! CurrencySendCTACollectionViewCell
        let fromFrame = feesPickerView.convert(
            cell.networkFeeView.networkFeeButton.bounds,
            from: cell.networkFeeView.networkFeeButton
        )
        feesPickerView.present(
            with: fees,
            onFeeSelected: makeOnFeeSelected(),
            at: .init(x: Theme.constant.padding, y: fromFrame.midY)
        )
    }
    
    @objc func dismissKeyboard() {
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
}

extension CurrencySendViewController: UICollectionViewDataSource {
    
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
            let cell = collectionView.dequeue(CurrencySendToCollectionViewCell.self, for: indexPath)
            cell.update(with: value, handler: tokenSendTokenHandler())
            return cell
        case let .token(token):
            let cell = collectionView.dequeue(CurrencySendTokenCollectionViewCell.self, for: indexPath)
            cell.update(with: token, handler: tokenSendTokenHandler())
            return cell
        case let .send(cta):
            let cell = collectionView.dequeue(CurrencySendCTACollectionViewCell.self, for: indexPath)
            cell.update(with: cta, handler: tokenSendCTAHandler())
            return cell
        }
    }
}

extension CurrencySendViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
}

private extension CurrencySendViewController {
    
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
    
    func makeOnFeeSelected() -> ((FeesPickerViewModel) -> Void) {
        { [weak self] item in self?.onTapped(.feeChanged(to: item.id))() }
    }
    
    @objc func navBarLeftActionTapped() {
        presenter.handle(.dismiss)
    }
}

private extension CurrencySendViewController {
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return nil }
            switch sectionIndex {
            case 0: return self.collectionLayoutSection(sectionIndex: sectionIndex)
            case 1: return self.collectionLayoutSection(sectionIndex: sectionIndex)
            case 2: return self.collectionLayoutSection(sectionIndex: sectionIndex)
            default: fatalError()
            }
        }
    }
    
    func collectionLayoutSection(sectionIndex: Int) -> NSCollectionLayoutSection {
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
            top: sectionIndex == 0 ? sectionInset : 0,
            leading: sectionInset,
            bottom: sectionIndex == 1 ? 0 : sectionInset,
            trailing: sectionInset
        )
        return section
    }
    
    func updateCells() {
        collectionView.visibleCells.forEach {
            switch $0 {
            case let addressCell as CurrencySendToCollectionViewCell:
                guard let address = viewModel?.items.address else { return }
                addressCell.update(with: address, handler: tokenSendTokenHandler())
            case let tokenCell as CurrencySendTokenCollectionViewCell:
                guard let token = viewModel?.items.token else { return }
                tokenCell.update(with: token, handler: tokenSendTokenHandler())
            case let ctaCell as CurrencySendCTACollectionViewCell:
                guard let cta = viewModel?.items.send else { return }
                ctaCell.update(with: cta, handler: tokenSendCTAHandler())
            default:
                fatalError()
            }
        }
    }
}

private extension CurrencySendViewController {
    
    func tokenSendTokenHandler() -> NetworkAddressPickerView.Handler {
        .init(
            onAddressChanged: onAddressChanged(),
            onQRCodeScanTapped: onTapped(.qrCodeScan),
            onPasteTapped: onTapped(.pasteAddress),
            onSaveTapped: onTapped(.saveAddress)
        )
    }

    func onAddressChanged() -> (String) -> Void {
        { [weak self] value in self?.onTapped(.addressChanged(to: value))()}
    }
    
    func tokenSendTokenHandler() -> CurrencySendTokenCollectionViewCell.Handler {
        .init(
            onTokenTapped: onTapped(.selectCurrency),
            onTokenChanged: onTokenChanged()
        )
    }
    
    func onTokenChanged() -> (BigInt) -> Void {
        { [weak self] value in self?.onTapped(.currencyChanged(to: value))() }
    }
    
    func tokenSendCTAHandler() -> CurrencySendCTACollectionViewCell.Handler {
        .init(
            onNetworkFeesTapped: onTapped(.feeTapped),
            onCTATapped: onTapped(.review)
        )
    }
    
    func onTapped(_ event: CurrencySendPresenterEvent) -> () -> Void {
        { [weak self] in self?.presenter.handle(event) }
    }
}
