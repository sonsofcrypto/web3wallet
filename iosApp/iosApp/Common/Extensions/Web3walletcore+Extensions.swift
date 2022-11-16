// Created by web3d4v on 16/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: Account
extension DefaultAccountWireframe: AccountWireframe {
    func navigate(destination__________ destination: AccountWireframeDestination) { navigate(with: destination) }
}
extension AccountViewController: AccountView {
    func update(viewModel_________ viewModel: AccountViewModel) { update(with: viewModel) }
}
extension AccountPresenter {
    func handle(event: AccountPresenterEvent) { handle(event_____________: event) }
}

// MARK: Alert
extension DefaultAlertWireframe: AlertWireframe {
    func navigate(destination___________________ destination: AlertWireframeDestination) { navigate(with: destination) }
}
extension AlertViewController: AlertView {
    func update(viewModel___________________ viewModel: AlertViewModel) { update(with: viewModel) }
}
extension AlertPresenter {
    func handle(event: AlertPresenterEvent) { handle(event_______________________: event) }
}

// MARK: Authenticate
extension DefaultAuthenticateWireframe: AuthenticateWireframe {
    func navigate(destination______________________ destination: AuthenticateWireframeDestination) { navigate(with: destination) }
}
extension AuthenticateViewController: AuthenticateView {
    func update(viewModel______________________ viewModel: AuthenticateViewModel) { update(with: viewModel) }
}
extension AuthenticatePresenter {
    func handle(event: AuthenticatePresenterEvent) { handle(event__________________________: event) }
}

// MARK: Confirmation
extension DefaultConfirmationWireframe: ConfirmationWireframe {
    func navigate(destination_______________ destination: ConfirmationWireframeDestination) { navigate(with: destination) }
}
extension ConfirmationViewController: ConfirmationView {
    func update(viewModel_______________ viewModel: ConfirmationViewModel) { update(with: viewModel) }
}
extension ConfirmationPresenter {
    func handle(event: ConfirmationPresenterEvent) { handle(event___________________: event) }
}

// MARK: CurrencyAdd
extension DefaultCurrencyAddWireframe: CurrencyAddWireframe {
    func navigate(destination________________ destination: CurrencyAddWireframeDestination) { navigate(with: destination) }
}
extension CurrencyAddViewController: CurrencyAddView {
    func update(viewModel________________ viewModel: CurrencyAddViewModel) { update(with: viewModel) }
}
extension CurrencyAddPresenter {
    func handle(event: CurrencyAddPresenterEvent) { handle(event____________________: event) }
}

// MARK: CurrencyPicker
extension DefaultCurrencyPickerWireframe: CurrencyPickerWireframe {
    func navigate(destination____________________ destination: CurrencyPickerWireframeDestination) { navigate(with: destination) }
}
extension CurrencyPickerViewController: CurrencyPickerView {
    func update(viewModel____________________ viewModel: CurrencyPickerViewModel) { update(with: viewModel) }
}
extension CurrencyPickerPresenter {
    func handle(event: CurrencyPickerPresenterEvent) { handle(event________________________: event) }
}

// MARK: CurrencyReceive
extension DefaultCurrencyReceiveWireframe: CurrencyReceiveWireframe {
    func navigate(destination_________ destination: CurrencyReceiveWireframeDestination) { navigate(with: destination) }
}
extension CurrencyReceiveViewController: CurrencyReceiveView {
    func update(viewModel________ viewModel: CurrencyReceiveViewModel) { update(with: viewModel) }
}
extension CurrencyReceivePresenter {
    func handle(event: CurrencyReceivePresenterEvent) { handle(event____________: event) }
}

// MARK: CurrencySend
extension DefaultCurrencySendWireframe: CurrencySendWireframe {
    func navigate(destination_____ destination: CurrencySendWireframeDestination) { navigate(with: destination) }
}
extension CurrencySendViewController: CurrencySendView {
    func update(viewModel_____ viewModel: CurrencySendViewModel) { update(with: viewModel) }
}
extension CurrencySendPresenter {
    func handle(event: CurrencySendPresenterEvent) { handle(event_________: event) }
}

// MARK: CurrencySwap
extension DefaultCurrencySwapWireframe: CurrencySwapWireframe {
    func navigate(destination__________________ destination: CurrencySwapWireframeDestination) { navigate(with: destination) }
}
extension CurrencySwapViewController: CurrencySwapView {
    func update(viewModel__________________ viewModel: CurrencySwapViewModel) { update(with: viewModel) }
}
extension CurrencySwapPresenter {
    func handle(event: CurrencySwapPresenterEvent) { handle(event______________________: event) }
}

// MARK: CultProposal
extension DefaultCultProposalWireframe: CultProposalWireframe {
    func navigate(destination: CultProposalWireframeDestination) { navigate(with: destination) }
}
extension CultProposalViewController: CultProposalView {
    func update(viewModel: CultProposalViewModel) { update(with: viewModel) }
}
extension CultProposalPresenter {
    func handle(event: CultProposalPresenterEvent) { handle(event____: event) }
}

// MARK: CultProposals
extension DefaultCultProposalsWireframe: CultProposalsWireframe {
    func navigate(destination_____________ destination: CultProposalsWireframeDestination) { navigate(with: destination) }
}
extension CultProposalsViewController: CultProposalsView {
    func update(viewModel____________ viewModel: CultProposalsViewModel) { update(with: viewModel) }
}
extension CultProposalsPresenter {
    func handle(event: CultProposalsPresenterEvent) { handle(event________________: event) }
}

// MARK: Degen
extension DefaultDegenWireframe: DegenWireframe {
    func navigate(destination__ destination: DegenWireframeDestination) { navigate(with: destination) }
}
extension DegenViewController: DegenView {
    func update(viewModel__ viewModel: DegenViewModel) { update(with: viewModel) }
}
extension DegenPresenter {
    func handle(event: DegenPresenterEvent) { handle(event______: event) }
}

// MARK: KeyStore
extension DefaultKeyStoreWireframe: KeyStoreWireframe {
    func navigate(destination____ destination: KeyStoreWireframeDestination) { navigate(with: destination) }
}
extension KeyStoreViewController: KeyStoreView {
    func update(viewModel____ viewModel: KeyStoreViewModel) { update(with: viewModel) }
}
extension KeyStorePresenter {
    func handle(event: KeyStorePresenterEvent) { handle(event________: event) }
}

// MARK: MnemonicConfirmation
extension DefaultMnemonicConfirmationWireframe: MnemonicConfirmationWireframe {
    func navigate(destination___________ destination: MnemonicConfirmationWireframeDestination) { navigate(with: destination) }
}
extension MnemonicConfirmationViewController: MnemonicConfirmationView {
    func update(viewModel__________ viewModel: MnemonicConfirmationViewModel) { update(with: viewModel) }
}
extension MnemonicConfirmationPresenter {
    func handle(event: MnemonicConfirmationPresenterEvent) { handle(event______________: event) }
}

// MARK: Networks
extension DefaultNetworksWireframe: NetworksWireframe {
    func navigate(destination_________________ destination: NetworksWireframeDestination) { navigate(with: destination) }
}
extension NetworksViewController: NetworksView {
    func update(viewModel_________________ viewModel: NetworksViewModel) { update(with: viewModel)}
}
extension NetworksPresenter {
    func handle(event: NetworksPresenterEvent) { handle(event_____________________: event) }
}

// MARK: NetworkSettings
extension DefaultNetworkSettingsWireframe: NetworkSettingsWireframe {
    //func navigate(destination__ destination: NetworksSettingsWireframeDestination) { navigate(with: destination) }
}
extension NetworkSettingsViewController: NetworkSettingsView {
    func update(viewModel_____________ viewModel: NetworkSettingsViewModel) { update(with: viewModel)}
}
extension NetworkSettingsPresenter {
    func handle(event: NetworkSettingsPresenterEvent) { handle(event_________________: event) }
}

// MARK: NFTDetail
extension DefaultNFTDetailWireframe: NFTDetailWireframe {
    func navigate(destination________ destination: NFTDetailWireframeDestination) { navigate(with: destination) }
}
extension NFTDetailViewController: NFTDetailView {
    func update(viewModel_______ viewModel: NFTDetailViewModel) { update(with: viewModel)}
}
extension NFTDetailPresenter {
    func handle(event: NFTDetailPresenterEvent) { handle(event___________: event) }
}

// MARK: NFTsCollection
extension DefaultNFTsCollectionWireframe: NFTsCollectionWireframe {
    func navigate(destination_ destination: NFTsCollectionWireframeDestination) { navigate(with: destination) }
}
extension NFTsCollectionViewController: NFTsCollectionView {
    func update(viewModel_ viewModel: NFTsCollectionViewModel) { update(with: viewModel)}
}
extension NFTsCollectionPresenter {
    func handle(event: NFTsCollectionPresenterEvent) { handle(event_____: event) }
}

// MARK: NFTsDashboard
extension DefaultNFTsDashboardWireframe: NFTsDashboardWireframe {
    func navigate(destination_____________________ destination: NFTsDashboardWireframeDestination) { navigate(with: destination) }
}
extension NFTsDashboardViewController: NFTsDashboardView {
    func update(viewModel_____________________ viewModel: NFTsDashboardViewModel) { update(with: viewModel)}
}
extension NFTsDashboardPresenter {
    func handle(event: NFTsDashboardPresenterEvent) { handle(event_________________________: event) }
}

// MARK: NFTSend
extension DefaultNFTSendWireframe: NFTSendWireframe {
    func navigate(destination____________ destination: NFTSendWireframeDestination) { navigate(with: destination) }
}
extension NFTSendViewController: NFTSendView {
    func update(viewModel___________ viewModel: NFTSendViewModel) { update(with: viewModel)}
}
extension NFTSendPresenter {
    func handle(event: NFTSendPresenterEvent) { handle(event_______________: event) }
}

// MARK: ImprovementProposal
extension DefaultImprovementProposalWireframe: ImprovementProposalWireframe {
    func navigate(destination___ destination: ImprovementProposalWireframeDestination) { navigate(with: destination) }
}
extension ImprovementProposalViewController: ImprovementProposalView {
    func update(viewModel___ viewModel: ImprovementProposalViewModel) { update(with: viewModel)}
}
extension ImprovementProposalPresenter {
    func handle(event: ImprovementProposalPresenterEvent) { handle(event_______: event) }
}

// MARK: ImprovementProposals
extension DefaultImprovementProposalsWireframe: ImprovementProposalsWireframe {
    func navigate(destination______________ destination: ImprovementProposalsWireframeDestination) { navigate(with: destination) }
}
extension ImprovementProposalsViewController: ImprovementProposalsView {
    func update(viewModel______________ viewModel: ImprovementProposalsViewModel) { update(with: viewModel)}
}
extension ImprovementProposalsPresenter {
    func handle(event: ImprovementProposalsPresenterEvent) { handle(event__________________: event) }
}

// MARK: QRCodeScan
extension DefaultQRCodeScanWireframe: QRCodeScanWireframe {
    func navigate(destination______ destination: QRCodeScanWireframeDestination) { navigate(with: destination) }
}
extension QRCodeScanViewController: QRCodeScanView {
    func update(viewModel______ viewModel: QRCodeScanViewModel) { update(with: viewModel)}
}
extension QRCodeScanPresenter {
    func handle(event: QRCodeScanPresenterEvent) { handle(event__________: event) }
}
