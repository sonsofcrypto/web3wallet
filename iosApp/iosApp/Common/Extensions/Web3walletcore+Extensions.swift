// Created by web3d4v on 16/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: Alert

extension AlertViewController: AlertView {
    func update(viewModel________________ viewModel: AlertViewModel) { update(with: viewModel) }
}
extension AlertPresenter {
    func handle(event: AlertPresenterEvent) { handle(event____________________: event) }
}

// MARK: Authenticate

extension AuthenticateViewController: AuthenticateView {
    func update(viewModel___________________ viewModel: AuthenticateViewModel) { update(with: viewModel) }
}
extension AuthenticatePresenter {
    func handle(event: AuthenticatePresenterEvent) { handle(event_______________________: event) }
}

// MARK: Confirmation

extension ConfirmationViewController: ConfirmationView {
    func update(viewModel____________ viewModel: ConfirmationViewModel) { update(with: viewModel) }
}
extension ConfirmationPresenter {
    func handle(event: ConfirmationPresenterEvent) { handle(event________________: event) }
}

// MARK: CurrencyAdd
extension CurrencyAddViewController: CurrencyAddView {
    func update(viewModel_____________ viewModel: CurrencyAddViewModel) { update(with: viewModel) }
}
extension CurrencyAddPresenter {
    func handle(event: CurrencyAddPresenterEvent) { handle(event_________________: event) }
}

// MARK: CurrencyPicker
extension CurrencyPickerViewController: CurrencyPickerView {
    func update(viewModel_________________ viewModel: CurrencyPickerViewModel) { update(with: viewModel) }
}
extension CurrencyPickerPresenter {
    func handle(event: CurrencyPickerPresenterEvent) { handle(event_____________________: event) }
}

// MARK: CurrencyReceive
extension CurrencyReceiveViewController: CurrencyReceiveView {
    func update(viewModel_______ viewModel: CurrencyReceiveViewModel) { update(with: viewModel) }
}
extension CurrencyReceivePresenter {
    func handle(event: CurrencyReceivePresenterEvent) { handle(event___________: event) }
}

// MARK: CurrencySend
extension CurrencySendViewController: CurrencySendView {
    func update(viewModel____ viewModel: CurrencySendViewModel) { update(with: viewModel) }
}
extension CurrencySendPresenter {
    func handle(event: CurrencySendPresenterEvent) { handle(event________: event) }
}

// MARK: CurrencySwap
extension CurrencySwapViewController: CurrencySwapView {
    func update(viewModel_______________ viewModel: CurrencySwapViewModel) { update(with: viewModel) }
}
extension CurrencySwapPresenter {
    func handle(event: CurrencySwapPresenterEvent) { handle(event___________________: event) }
}

// MARK: CultProposal
extension CultProposalViewController: CultProposalView {
    func update(viewModel: CultProposalViewModel) { update(with: viewModel) }
}
extension CultProposalPresenter {
    func handle(event: CultProposalPresenterEvent) { handle(event____: event) }
}

// MARK: CultProposals
extension CultProposalsViewController: CultProposalsView {
    func update(viewModel_________ viewModel: CultProposalsViewModel) { update(with: viewModel) }
}
extension CultProposalsPresenter {
    func handle(event: CultProposalsPresenterEvent) { handle(event_____________: event) }
}

// MARK: Degen
extension DegenViewController: DegenView {
    func update(viewModel__ viewModel: DegenViewModel) { update(with: viewModel) }
}
extension DegenPresenter {
    func handle(event: DegenPresenterEvent) { handle(event______: event) }
}

// MARK: Networks
extension NetworksViewController: NetworksView {
    func update(viewModel______________ viewModel: NetworksViewModel) { update(with: viewModel)}
}
extension NetworksPresenter {
    func handle(event: NetworksPresenterEvent) { handle(event__________________: event) }
}

// MARK: NetworkSettings
extension NetworkSettingsViewController: NetworkSettingsView {
    func update(viewModel__________ viewModel: NetworkSettingsViewModel) { update(with: viewModel)}
}
extension NetworkSettingsPresenter {
    func handle(event: NetworkSettingsPresenterEvent) { handle(event______________: event) }
}

// MARK: NFTDetail
extension NFTDetailViewController: NFTDetailView {
    func update(viewModel______ viewModel: NFTDetailViewModel) { update(with: viewModel)}
}
extension NFTDetailPresenter {
    func handle(event: NFTDetailPresenterEvent) { handle(event__________: event) }
}

// MARK: NFTsCollection
extension NFTsCollectionViewController: NFTsCollectionView {
    func update(viewModel_ viewModel: NFTsCollectionViewModel) { update(with: viewModel)}
}
extension NFTsCollectionPresenter {
    func handle(event: NFTsCollectionPresenterEvent) { handle(event_____: event) }
}

// MARK: NFTsDashboard
extension NFTsDashboardViewController: NFTsDashboardView {
    func update(viewModel__________________ viewModel: NFTsDashboardViewModel) { update(with: viewModel)}
}
extension NFTsDashboardPresenter {
    func handle(event: NFTsDashboardPresenterEvent) { handle(event______________________: event) }
}

// MARK: NFTSend
extension NFTSendViewController: NFTSendView {
    func update(viewModel________ viewModel: NFTSendViewModel) { update(with: viewModel)}
}
extension NFTSendPresenter {
    func handle(event: NFTSendPresenterEvent) { handle(event____________: event) }
}

// MARK: ImprovementProposal
extension ImprovementProposalViewController: ImprovementProposalView {
    func update(viewModel___ viewModel: ImprovementProposalViewModel) { update(with: viewModel)}
}
extension ImprovementProposalPresenter {
    func handle(event: ImprovementProposalPresenterEvent) { handle(event_______: event) }
}

// MARK: ImprovementProposals
extension ImprovementProposalsViewController: ImprovementProposalsView {
    func update(viewModel___________ viewModel: ImprovementProposalsViewModel) { update(with: viewModel)}
}
extension ImprovementProposalsPresenter {
    func handle(event: ImprovementProposalsPresenterEvent) { handle(event_______________: event) }
}

// MARK: QRCodeScan
extension QRCodeScanViewController: QRCodeScanView {
    func update(viewModel_____ viewModel: QRCodeScanViewModel) { update(with: viewModel)}
}
extension QRCodeScanPresenter {
    func handle(event: QRCodeScanPresenterEvent) { handle(event_________: event) }
}
