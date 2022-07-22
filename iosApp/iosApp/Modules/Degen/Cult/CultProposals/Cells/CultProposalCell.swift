// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class CultProposalCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var approvedVoteView: CultProposalVoteView!
    @IBOutlet weak var rejectedVoteView: CultProposalVoteView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var approveButton: Button!
    @IBOutlet weak var rejectButton: Button!
    private weak var labelView: LabelView!

    private var timer: Timer? = nil
    private var date: Date = .distantPast
    
    private var viewModel: CultProposalsViewModel.Item!
    private var handler: Handler!
    
    struct Handler {
        
        let approveProposal: (String) -> Void
        let rejectProposal: (String) -> Void
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        titleLabel.apply(style: .body, weight: .bold)
        
        chevronImageView.tintColor = Theme.colour.labelPrimary
        
        approveButton.style = .primary
        approveButton.addTarget(self, action: #selector(approveProposal), for: .touchUpInside)
        rejectButton.style = .primary
        rejectButton.addTarget(self, action: #selector(rejectProposal), for: .touchUpInside)
        
        clipsToBounds = false
        
        let labelView = LabelView()
        addSubview(labelView)
        self.labelView = labelView
        labelView.addConstraints(
            [
                .layout(
                    anchor: .topAnchor,
                    constant: .equalTo(constant: -8)
                ),
                .layout(
                    anchor: .trailingAnchor,
                    constant: .equalTo(
                        constant: Theme.constant.padding
                    )
                )
            ]
        )
    }
    
    func update(
        with viewModel: CultProposalsViewModel.Item,
        handler: Handler
    ) {
        self.viewModel = viewModel
        self.handler = handler
        
        labelView.isHidden = !viewModel.isNew
        
        titleLabel.text = viewModel.title
        approvedVoteView.update(
            viewModel: viewModel.approved
        )
        rejectedVoteView.update(
            viewModel: viewModel.rejected
        )
        statusLabel.text = "Proposal status"
        date = viewModel.date
        
        approveButton.setTitle(viewModel.approveButtonTitle, for: .normal)
        rejectButton.setTitle(viewModel.rejectButtonTitle, for: .normal)
        
        updateDate()
    }

    override func didMoveToWindow() {
        
        super.didMoveToWindow()
        
        if let _ = window, timer == nil {
            let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.updateDate()
            }
            self.timer = timer
            
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
}

private extension CultProposalCell  {
    
    func updateDate() {
        
        let comps = Calendar.current.dateComponents(
            [.day, .hour, .minute, .second],
            from: Date(),
            to: date
        )
        let days = comps.day ?? 0
        let hours = comps.hour ?? 0
        let minutes = comps.minute ?? 0
        let seconds = comps.second ?? 0
        
        statusLabel.text = String(
            format: "%02d:%02d:%02d:%02d", days, hours, minutes, seconds
        )
    }
    
    @objc func approveProposal() {
        
        handler.approveProposal(viewModel.id)
    }

    @objc func rejectProposal() {
        
        handler.rejectProposal(viewModel.id)
    }
}

private final class LabelView: UIView {
    
    private weak var label: UILabel!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        
        backgroundColor = Theme.colour.candleGreen
        layer.cornerRadius = Theme.constant.cornerRadiusSmall
        
        let label = UILabel()
        label.apply(style: .callout, weight: .bold)
        label.text = Localized("new").uppercased()
        self.addSubview(label)
        self.label = label
        label.addConstraints(
            [
                .layout(anchor: .topAnchor, constant: .equalTo(constant: 4)),
                .layout(anchor: .bottomAnchor, constant: .equalTo(constant: 4)),
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: 8)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: 8))
            ]
        )
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        guard let superview = superview else { return }
        sendSubviewToBack(superview)
    }
}
