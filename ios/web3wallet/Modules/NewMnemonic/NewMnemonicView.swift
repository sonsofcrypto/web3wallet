// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NewMnemonicView: AnyObject {

    func update(with viewModel: NewMnemonicViewModel)
}

class NewMnemonicViewController: UIViewController {

    var presenter: NewMnemonicPresenter!

    private var viewModel: NewMnemonicViewModel?
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    // MARK: - Actions

    @IBAction func templateAction(_ sender: Any) {

    }
}

// MARK: - NewMnemonic

extension NewMnemonicViewController: NewMnemonicView {

    func update(with viewModel: NewMnemonicViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension NewMnemonicViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.sectionsItems.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.sectionsItems[safe: section]?.count ?? 0
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel?.item(at: indexPath) else {
            fatalError("Wrong number of items in section \(indexPath)")
        }
        let cell = cell(cv: collectionView, viewModel: viewModel, idxPath: indexPath)
        if indexPath.section == 1 {

            (cell as? CollectionViewCell)?.cornerStyle = .middle

            if indexPath.item == 0 {
                (cell as? CollectionViewCell)?.cornerStyle = .top
            }

            if indexPath.item == (self.viewModel?.sectionsItems[safe: 1]?.count ?? 0) - 1 {
                (cell as? CollectionViewCell)?.cornerStyle = .bottom
            }
        }
        return cell
    }

    func cell(cv: UICollectionView, viewModel: NewMnemonicViewModel.Item, idxPath: IndexPath) -> UICollectionViewCell {
        switch viewModel {

        case let .mnemonic(mnemonic):
            return collectionView.dequeue(NewMnemonicCell.self, for: idxPath)
                    .update(with: mnemonic)

        case let .name(name):
            return collectionView.dequeue(
                CollectionViewTextInputCell.self,
                for: idxPath
            ).update(
                with: name,
                textChangeHandler: { value in self.nameDidChange(value) }
            )

        case let .onOffSwitch(title, onOff):
            return collectionView.dequeue(
                CollectionViewSwitchCell.self,
                for: idxPath
            ).update(
                with: title,
                onOff: onOff,
                handler: { value in self.iCloudBackupDidChange(value) }
            )
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {

        case UICollectionView.elementKindSectionHeader:
            fatalError("Handle header \(kind) \(indexPath)")

        case UICollectionView.elementKindSectionFooter:
            guard let viewModel = viewModel?.footer(at: indexPath.section) else {
                fatalError("Failed to handle \(kind) \(indexPath)")
            }

            let footer = collectionView.dequeue(
                CollectionViewSectionLabelFooter.self,
                for: indexPath,
                kind: kind
            )

            footer.update(with: viewModel)
            return footer

        default:
            ()
        }
        fatalError("Failed to handle \(kind) \(indexPath)")
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension NewMnemonicViewController: UICollectionViewDelegate {

    func nameDidChange(_ name: String) {
        presenter.handle(.didChangeName(name: name))
    }

    func iCloudBackupDidChange(_ onOff: Bool) {
        presenter.handle(.didChangeICouldBackup(onOff: onOff))
    }
}

extension NewMnemonicViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width - Global.padding * 2

        guard let viewModel = viewModel?.item(at: indexPath) else {
            return CGSize(width: width, height: Global.cellHeight)
        }

        switch viewModel {
        case let .mnemonic(mnemonic):
            return CGSize(width: width, height: Constant.mnemonicCellHeight)
        default:
            return CGSize(width: width, height: Constant.cellHeight)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let header = viewModel?.header(at: section) else {
            return .zero
        }

        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let footer = viewModel?.footer(at: section) else {
            return .zero
        }

        switch footer {
        case .attrStr:
            return .init(width: view.bounds.width, height: Constant.footerHeight)
        default:
            return .zero
        }
    }
}

// MARK: - Configure UI

extension NewMnemonicViewController {
    
    func configureUI() {
        title = Localized("newMnemonic.title")
        (view as? GradientView)?.colors = [
            Theme.current.background,
            Theme.current.backgroundDark
        ]
    }
}

// MARK: - Constants

extension NewMnemonicViewController {

    enum Constant {
        static let mnemonicCellHeight: CGFloat = 110
        static let cellHeight: CGFloat = 46
        static let footerHeight: CGFloat = 52

    }
}
