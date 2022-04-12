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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.sectionsItems.count ?? 0
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel?.item(at: indexPath) else {
            fatalError("Wrong number of items in section \(indexPath)")
        }

        switch viewModel {
        case let .mnemonic(mnemonic):
            let cell = collectionView.dequeue(NewMnemonicCell.self, for: indexPath)
            cell.update(with: mnemonic)
            return cell
        }

        fatalError("Not handled \(indexPath)")
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
}

extension NewMnemonicViewController: UICollectionViewDelegate {
    
}

extension NewMnemonicViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: collectionView.frame.width - Global.padding * 2,
            height: Constant.mnemonicCellHeight
        )
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let header = viewModel?.header(at: section) else {
            return .zero
        }

//        switch hearder {
//        case .attrStr:
//            return CGSize(
//                width: view.bounds.width - Global.padding * 2,
//                height: Constant.mnemonicFooterHeight
//            )
//        default:
//            return .zero
//        }
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
        title = Localized("wallets")
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
        static let footerHeight: CGFloat = 52
    }
}
