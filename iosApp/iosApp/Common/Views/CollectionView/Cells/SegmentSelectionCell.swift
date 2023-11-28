// Created by web3d3v on 27/11/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class SegmentSelectionCell: ThemeCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentControl: SegmentedControl!

    private var selectSegmentAction: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    override func applyTheme(_ theme: ThemeProtocol) {
        super.applyTheme(theme)
        titleLabel.font = theme.font.body
        titleLabel.textColor = theme.color.textPrimary
    }

    func update(
        with viewModel: CellViewModel.SegmentSelection,
        segmentHandler: ((Int) -> Void)?
    ) -> Self {
        
        self.titleLabel.text = viewModel.title
        self.selectSegmentAction = segmentHandler
    
        for (idx, item) in viewModel.values.enumerated() {
            if segmentControl.numberOfSegments <= idx {
                segmentControl.insertSegment(withTitle: item, at: idx, animated: false)
            } else {
                segmentControl.setTitle(item, forSegmentAt: idx)
            }
        }

        segmentControl.selectedSegmentIndex = viewModel.selectedIdx.int
        return self
    }


    @objc func segmentAction(_ sender: UISegmentedControl) {
        selectSegmentAction?(sender.selectedSegmentIndex)
    }


    private func configureUI() {
        segmentControl.addTarget(
            self,
            action: #selector(segmentAction(_:)),
            for: .valueChanged
        )
    }
}
