// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol CultProposalView: AnyObject {

    func update(with viewModel: CultProposalViewModel)
}

final class CultProposalViewController: BaseViewController {

    var presenter: CultProposalPresenter!
    
    @IBOutlet weak var collectionView: UICollectionView!

    private var viewModel: CultProposalViewModel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter.present()
    }
}

extension CultProposalViewController: CultProposalView {

    func update(with viewModel: CultProposalViewModel) {
        
        self.viewModel = viewModel
        
        setTitle(with: viewModel.selectedIndex + 1)
        
        collectionView.reloadData()
        collectionView.scrollToItem(
            at: .init(item: viewModel.selectedIndex, section: 0),
            at: .centeredHorizontally,
            animated: false
        )
    }
}

extension CultProposalViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        viewModel.proposals.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let viewModel = viewModel.proposals[indexPath.item]
        let cell = collectionView.dequeue(CultProposalDetailViewCell.self, for: indexPath)
        return cell.update(with: viewModel)
    }
}

extension CultProposalViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        setTitle(with: indexPath.item + 1)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {

        guard let visibleCell = collectionView.visibleCells.first else { return }
        guard let currentIndexPath = collectionView.indexPath(for: visibleCell) else { return }
        setTitle(with: currentIndexPath.item + 1)
    }
}

private extension CultProposalViewController {
    
    func setTitle(with index: Int) {
        
        let cultIcon = viewModel.titleIcon.pngImage!.resize(to: .init(width: 32, height: 32))
        let imageView = UIImageView(image: cultIcon)
        let titleLabel = UILabel()
        titleLabel.text = viewModel.title + " \(index) " + Localized("cult.proposal.title.of") + " \(viewModel.proposals.count)"
        titleLabel.apply(style: .navTitle)
        
        let stackView = HStackView([imageView, titleLabel])
        stackView.spacing = 4
        
        navigationItem.titleView = stackView
    }
    
    func configureUI() {
        
        collectionView.setCollectionViewLayout(
            makeCompositionalLayout(),
            animated: false
        )
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        UICollectionViewCompositionalLayout(
            section: makeCollectionLayoutSection()
        )
    }
  
    func makeCollectionLayoutSection(
    ) -> NSCollectionLayoutSection {
        
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )

        // Section
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        
        return section
    }
}
