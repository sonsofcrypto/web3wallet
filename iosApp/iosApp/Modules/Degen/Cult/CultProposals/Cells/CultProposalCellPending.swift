// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class CultProposalCellPending: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var approvedVoteView: CultProposalVoteView!
    @IBOutlet weak var approvedVotes: UILabel!
    @IBOutlet weak var rejectedVoteView: CultProposalVoteView!
    @IBOutlet weak var rejectedVotes: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var approveButton: Button!
    @IBOutlet weak var rejectButton: Button!
    private weak var statusView: StatusView!

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
        approvedVotes.apply(style: .footnote)
        rejectedVotes.apply(style: .footnote)

        chevronImageView.tintColor = Theme.colour.labelPrimary
        
        approveButton.style = .primary
        approveButton.addTarget(self, action: #selector(approveProposal), for: .touchUpInside)
        rejectButton.style = .primary
        rejectButton.addTarget(self, action: #selector(rejectProposal), for: .touchUpInside)
        
        clipsToBounds = false
        
        let statusView = StatusView()
        addSubview(statusView)
        self.statusView = statusView
        statusView.addConstraints(
            [
                .layout(
                    anchor: .topAnchor,
                    constant: .equalTo(constant: -12)
                ),
                .layout(
                    anchor: .trailingAnchor,
                    constant: .equalTo(
                        constant: Theme.constant.padding
                    )
                )
            ]
        )
        
        bottomSeparatorView.isHidden = true
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
    
    func update(
        with viewModel: CultProposalsViewModel.Item,
        handler: Handler
    ) -> Self {
        self.viewModel = viewModel
        self.handler = handler
        
        titleLabel.text = viewModel.title
        approvedVoteView.update(
            viewModel: viewModel.approved
        )
        approvedVotes.text = viewModel.approved.total.thowsandsFormatted()
        rejectedVoteView.update(
            viewModel: viewModel.rejected
        )
        rejectedVotes.text = viewModel.rejected.total.thowsandsFormatted()
        date = viewModel.endDate
        
        approveButton.setTitle(viewModel.approveButtonTitle, for: .normal)
        rejectButton.setTitle(viewModel.rejectButtonTitle, for: .normal)
        
        updateDate()
        
        return self
    }
}

private extension CultProposalCellPending  {
    
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
        
        var dateString = ""
        
        if days > 0 {
            dateString += Localized("time.until.day.shortest", arg: days.stringValue)
        }
        
        if hours > 0 || !dateString.isEmpty {
            let hoursFormatted = String(
                format: "%02d", hours
            )
            dateString += dateString.isEmpty ? "" : " "
            dateString += Localized("time.until.hour.shortest", arg: hoursFormatted)
        }

        if minutes > 0 || !dateString.isEmpty {
            let minutesFormatted = String(
                format: "%02d", minutes
            )
            dateString += dateString.isEmpty ? "" : " "
            dateString += Localized("time.until.min.shortest", arg: minutesFormatted)
        }

        if seconds > 0 || !dateString.isEmpty {
            let secondsFormatted = String(
                format: "%02d", seconds
            )
            dateString += dateString.isEmpty ? "" : " "
            dateString += Localized("time.until.sec.shortest", arg: secondsFormatted)
        }
        
        if dateString.isEmpty {
            
            dateString = Localized("cult.proposals.pending.processing")
        }

        statusView.text = dateString
    }
    
    @objc func approveProposal() {
        
        handler.approveProposal(viewModel.id)
    }

    @objc func rejectProposal() {
        
        handler.rejectProposal(viewModel.id)
    }
}

private final class StatusView: UIView {
    
    private weak var label: UILabel!
    
    var text: String = "" {
        
        didSet {
            
            label.text = text
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        
        backgroundColor = Theme.colour.navBarTint
        layer.cornerRadius = Theme.constant.cornerRadiusSmall
        
        let label = UILabel()
        label.apply(style: .footnote, weight: .bold)
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
}
