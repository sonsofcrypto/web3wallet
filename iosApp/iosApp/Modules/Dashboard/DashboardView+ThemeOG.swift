// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension DashboardViewController {
    
    func configureThemeOG() {
        
        collectionView.register(
            DashboardSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(DashboardSectionHeaderView.self)"
        )
        
        var insets = collectionView.contentInset
        insets.bottom += Global.padding
        collectionView.contentInset = insets

        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0
        collectionView.layer.sublayerTransform = transform

        let overScrollView = (collectionView as? CollectionView)
        overScrollView?.overScrollView.image = UIImage(named: "overscroll_pepe")
    }
    
    func updateThemeOG() {
        
        collectionView.reloadData()
    }
}

extension DashboardViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.sections.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let section = viewModel?.sections[section] else {
            return 0
        }
        return section.wallets.count + (section.nfts.count > 0 ? 1 : 0)
    }
    

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
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

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            switch indexPath.section {
                
            case 0:
                let supplementary = collectionView.dequeue(
                    DashboardHeaderView.self,
                    for: indexPath,
                    kind: kind
                )
                supplementary.update(with: viewModel?.header, presenter: presenter)
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

extension DashboardViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let length = (view.bounds.width - Global.padding * 2 - Constant.spacing) / 2
        
        if indexPath.item >= viewModel?.sections[indexPath.section].wallets.count ?? 0 {
            
            return .init(
                width: view.bounds.width - Global.padding * 2,
                height: length
            )
        }

        return .init(width: length, height: length)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        
        .init(
            width: view.bounds.width - Global.padding * 2,
            height: section == 0 ? Constant.headerHeight : Constant.sectionHeaderHeight
        )
    }
}

extension DashboardViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let section = viewModel?.sections[indexPath.section] else { return }
        let symbol = section.wallets[indexPath.item].ticker
        presenter.handle(.didSelectWallet(network: section.name, symbol: symbol))
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        
        guard lastVelocity > 0 else {
            return
        }

        let rotation = CATransform3DMakeRotation(-3.13 / 2, 1, 0, 0)
        let anim = CABasicAnimation(keyPath: "transform")
        anim.fromValue = CATransform3DScale(rotation, 0.5, 0.5, 0)
        anim.toValue = CATransform3DIdentity
        anim.duration = 0.3
        anim.isRemovedOnCompletion = true
        anim.fillMode = .both
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        anim.beginTime = CACurrentMediaTime() + 0.05 * CGFloat(indexPath.item);
        cell.layer.add(anim, forKey: "transform")
    }
}
