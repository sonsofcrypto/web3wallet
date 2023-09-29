// Created by web3d4v on 16/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: Account
extension DefaultAccountWireframe: AccountWireframe {
    func navigate(destination_____________________ destination: AccountWireframeDestination) { navigate(to: destination) }
}
extension AccountViewController: AccountView {
    func update(viewModel_____________________ viewModel: AccountViewModel) { update(with: viewModel) }
}
extension AccountPresenter {
    func handle(_ event: AccountPresenterEvent) { handle(event__________________________: event)  }
}

// MARK: Alert
extension DefaultAlertWireframe: AlertWireframe {
    func navigate(destination____________ destination: AlertWireframeDestination) { navigate(to: destination) }
}
extension AlertViewController: AlertView {
    func update(viewModel_____________ viewModel: AlertViewModel) { update(with: viewModel) }
}
extension AlertPresenter {
    func handle(_ event: AlertPresenterEvent) { handle(event_________________: event) }
}

// MARK: Authenticate
extension DefaultAuthenticateWireframe: AuthenticateWireframe {
    func navigate(destination___________________________ destination: AuthenticateWireframeDestination) { navigate(to: destination) }
}
extension AuthenticateViewController: AuthenticateView {
    func update(viewModel___________________________ viewModel: AuthenticateViewModel) { update(with: viewModel) }
}
extension AuthenticatePresenter {
    func handle(_ event: AuthenticatePresenterEvent) { handle(event________________________________: event) }
}

// MARK: Confirmation
extension DefaultConfirmationWireframe: ConfirmationWireframe {
    func navigate(destination__________ destination: ConfirmationWireframeDestination) { navigate(to: destination) }
}
extension ConfirmationViewController: ConfirmationView {
    func update(viewModel___________ viewModel: ConfirmationViewModel) { update(with: viewModel) }
}
extension ConfirmationPresenter {
    func handle(_ event: ConfirmationPresenterEvent) { handle(event_______________: event) }
}

// MARK: CurrencyAdd
extension DefaultCurrencyAddWireframe: CurrencyAddWireframe {
    func navigate(destination_________ destination: CurrencyAddWireframeDestination) { navigate(to: destination) }
}
extension CurrencyAddViewController: CurrencyAddView {
    func update(viewModel__________ viewModel: CurrencyAddViewModel) { update(with: viewModel) }
}
extension CurrencyAddPresenter {
    func handle(_ event: CurrencyAddPresenterEvent) { handle(event______________: event) }
}

// MARK: CurrencyPicker
extension DefaultCurrencyPickerWireframe: CurrencyPickerWireframe {
    func navigate(destination__________________________ destination: CurrencyPickerWireframeDestination) { navigate(to: destination) }
}
extension CurrencyPickerViewController: CurrencyPickerView {
    func update(viewModel__________________________ viewModel: CurrencyPickerViewModel) { update(with: viewModel) }
}
extension CurrencyPickerPresenter {
    func handle(_ event: CurrencyPickerPresenterEvent) { handle(event_______________________________: event) }
}

// MARK: CurrencyReceive
extension DefaultCurrencyReceiveWireframe: CurrencyReceiveWireframe {
    func navigate(destination___________________ destination: CurrencyReceiveWireframeDestination) { navigate(to: destination) }
}
extension CurrencyReceiveViewController: CurrencyReceiveView {
    func update(viewModel___________________ viewModel: CurrencyReceiveViewModel) { update(with: viewModel) }
}
extension CurrencyReceivePresenter {
    func handle(_ event: CurrencyReceivePresenterEvent) { handle(event_______________________: event) }
}

// MARK: CurrencySend
extension DefaultCurrencySendWireframe: CurrencySendWireframe {
    func navigate(destination________________ destination: CurrencySendWireframeDestination) { navigate(to: destination) }
}
extension CurrencySendViewController: CurrencySendView {
    func update(viewModel_________________ viewModel: CurrencySendViewModel) { update(with: viewModel) }
}
extension CurrencySendPresenter {
    func handle(_ event: CurrencySendPresenterEvent) { handle(event_____________________: event) }
}

// MARK: CurrencySwap
extension DefaultCurrencySwapWireframe: CurrencySwapWireframe {
    func navigate(destination_________________________ destination: CurrencySwapWireframeDestination) { navigate(to: destination) }
}
extension CurrencySwapViewController: CurrencySwapView {
    func update(viewModel_________________________ viewModel: CurrencySwapViewModel) { update(with: viewModel) }
}
extension CurrencySwapPresenter {
    func handle(_ event: CurrencySwapPresenterEvent) { handle(event______________________________: event) }
}

// MARK: Dashboard
extension DefaultDashboardWireframe: DashboardWireframe {
    func navigate(destination____________________ destination: DashboardWireframeDestination) { navigate(to: destination) }
}
extension DashboardViewController: DashboardView {
    func update(viewModel____________________ viewModel: DashboardViewModel) { update(with: viewModel) }
}
extension DashboardPresenter {
    func handle(_ event: DashboardPresenterEvent) { handle(event_________________________: event) }
}


// MARK: CultProposal
extension DefaultCultProposalWireframe: CultProposalWireframe {
    func navigate(destination_ destination: CultProposalWireframeDestination) { navigate(to: destination) }
}
extension CultProposalViewController: CultProposalView {
    func update(viewModel_ viewModel: CultProposalViewModel) { update(with: viewModel) }
}
extension CultProposalPresenter {
    func handle(_ event: CultProposalPresenterEvent) { handle(event_____: event) }
}

// MARK: CultProposals
extension DefaultCultProposalsWireframe: CultProposalsWireframe {
    func navigate(destination______ destination: CultProposalsWireframeDestination) { navigate(to: destination) }
}
extension CultProposalsViewController: CultProposalsView {
    func update(viewModel______ viewModel: CultProposalsViewModel) { update(with: viewModel) }
}
extension CultProposalsPresenter {
    func handle(_ event: CultProposalsPresenterEvent) { handle(event__________: event) }
}

// MARK: Degen
extension DefaultDegenWireframe: DegenWireframe {
    func navigate(destination_______________ destination: DegenWireframeDestination) { navigate(to: destination) }
}
extension DegenViewController: DegenView {
    func update(viewModel________________ viewModel: DegenViewModel) { update(with: viewModel) }
}
extension DegenPresenter {
    func handle(_ event: DegenPresenterEvent) { handle(event____________________: event) }
}

// MARK: KeyStore
extension DefaultKeyStoreWireframe: KeyStoreWireframe {
    func navigate(destination___ destination: KeyStoreWireframeDestination) { navigate(to: destination) }
}
extension KeyStoreViewController: KeyStoreView {
    func update(viewModel___ viewModel: KeyStoreViewModel) { update(with: viewModel) }
}
extension KeyStorePresenter {
    func handle(_ event: KeyStorePresenterEvent) { handle(event_______: event) }
}

// MARK: MnemonicConfirmation
extension DefaultMnemonicConfirmationWireframe: MnemonicConfirmationWireframe {
    func navigate(destination_____ destination: MnemonicConfirmationWireframeDestination) { navigate(to: destination) }
}
extension MnemonicConfirmationViewController: MnemonicConfirmationView {
    func update(viewModel_____ viewModel: MnemonicConfirmationViewModel) { update(with: viewModel) }
}
extension MnemonicConfirmationPresenter {
    func handle(_ event: MnemonicConfirmationPresenterEvent) { handle(event_________: event) }
}

// MARK: MnemonicImport
extension DefaultMnemonicImportWireframe: MnemonicImportWireframe {
    func navigate(destination____________________________ destination: MnemonicImportWireframeDestination) { navigate(to: destination) }
}
extension MnemonicImportViewController: MnemonicImportView {
    func update(viewModel____________________________ viewModel: MnemonicImportViewModel) { update(with: viewModel) }
}
extension MnemonicImportPresenter {
    func handle(_ event: MnemonicImportPresenterEvent) { handle(event_________________________________: event) }
}

// MARK: MnemonicNew
extension DefaultMnemonicNewWireframe: MnemonicNewWireframe {
    func navigate(destination______________________ destination: MnemonicNewWireframeDestination) { navigate(to: destination) }
}
extension MnemonicNewViewController: MnemonicNewView {
    func update(viewModel______________________ viewModel: MnemonicNewViewModel) { update(with: viewModel) }
}
extension MnemonicNewPresenter {
    func handle(_ event: MnemonicNewPresenterEvent) { handle(event___________________________: event) }
}

// MARK: MnemonicUpdate
extension DefaultMnemonicUpdateWireframe: MnemonicUpdateWireframe {
    func navigate(destination: MnemonicUpdateWireframeDestination) { navigate(to: destination) }
}
extension MnemonicUpdateViewController: MnemonicUpdateView {
    func update(viewModel: MnemonicUpdateViewModel) { update(with: viewModel) }
}
extension MnemonicUpdatePresenter {
    func handle(_ event: MnemonicUpdatePresenterEvent) { handle(event____: event) }
}

// MARK: Networks
extension DefaultNetworksWireframe: NetworksWireframe {
    func navigate(destination________________________ destination: NetworksWireframeDestination) { navigate(to: destination) }
}
extension NetworksViewController: NetworksView {
    func update(viewModel________________________ viewModel: NetworksViewModel) { update(with: viewModel)}
}
extension NetworksPresenter {
    func handle(_ event: NetworksPresenterEvent) { handle(event_____________________________: event) }
}

// MARK: NetworkSettings
extension DefaultNetworkSettingsWireframe: NetworkSettingsWireframe {
    //func navigate(destination__ destination: NetworksSettingsLegacyWireframeDestination) { navigate(to: destination) }
}
extension NetworkSettingsViewController: NetworkSettingsView {
    func update(viewModel_______ viewModel: NetworkSettingsViewModel) { update(with: viewModel)}
}
extension NetworkSettingsPresenter {
    func handle(_ event: NetworkSettingsPresenterEvent) { handle(event___________: event) }
}

// MARK: NFTDetail
extension DefaultNFTDetailWireframe: NFTDetailWireframe {
    func navigate(destination____ destination: NFTDetailWireframeDestination) { navigate(to: destination) }
}
extension NFTDetailViewController: NFTDetailView {
    func update(viewModel____ viewModel: NFTDetailViewModel) { update(with: viewModel)}
}
extension NFTDetailPresenter {
    func handle(_ event: NFTDetailPresenterEvent) { handle(event________: event) }
}

// MARK: NFTsCollection
extension DefaultNFTsCollectionWireframe: NFTsCollectionWireframe {
    func navigate(destination__ destination: NFTsCollectionWireframeDestination) { navigate(to: destination) }
}
extension NFTsCollectionViewController: NFTsCollectionView {
    func update(viewModel__ viewModel: NFTsCollectionViewModel) { update(with: viewModel)}
}
extension NFTsCollectionPresenter {
    func handle(_ event: NFTsCollectionPresenterEvent) { handle(event______: event) }
}

// MARK: NFTsDashboard
extension DefaultNFTsDashboardWireframe: NFTsDashboardWireframe {
    func navigate(destination_____________ destination: NFTsDashboardWireframeDestination) { navigate(to: destination) }
}
extension NFTsDashboardViewController: NFTsDashboardView {
    func update(viewModel______________ viewModel: NFTsDashboardViewModel) { update(with: viewModel)}
}
extension NFTsDashboardPresenter {
    func handle(_ event: NFTsDashboardPresenterEvent) { handle(event__________________: event) }
}

// MARK: NFTSend
extension DefaultNFTSendWireframe: NFTSendWireframe {
    func navigate(destination_______________________ destination: NFTSendWireframeDestination) { navigate(to: destination) }
}
extension NFTSendViewController: NFTSendView {
    func update(viewModel_______________________ viewModel: NFTSendViewModel) { update(with: viewModel)}
}
extension NFTSendPresenter {
    func handle(_ event: NFTSendPresenterEvent) { handle(event____________________________: event) }
}

// MARK: ImprovementProposal
extension DefaultImprovementProposalWireframe: ImprovementProposalWireframe {
    func navigate(destination______________ destination: ImprovementProposalWireframeDestination) { navigate(to: destination) }
}
extension ImprovementProposalViewController: ImprovementProposalView {
    func update(viewModel_______________ viewModel: ImprovementProposalViewModel) { update(with: viewModel)}
}
extension ImprovementProposalPresenter {
    func handle(_ event: ImprovementProposalPresenterEvent) { handle(event___________________: event) }
}

// MARK: ImprovementProposals
extension DefaultImprovementProposalsWireframe: ImprovementProposalsWireframe {
    func navigate(destination_______ destination: ImprovementProposalsWireframeDestination) { navigate(to: destination) }
}
extension ImprovementProposalsViewController: ImprovementProposalsView {
    func update(viewModel________ viewModel: ImprovementProposalsViewModel) { update(with: viewModel)}
}
extension ImprovementProposalsPresenter {
    func handle(_ event: ImprovementProposalsPresenterEvent) { handle(event____________: event) }
}

// MARK: QRCodeScan
extension DefaultQRCodeScanWireframe: QRCodeScanWireframe {
    func navigate(destination_________________ destination: QRCodeScanWireframeDestination) { navigate(to: destination) }
}
extension QRCodeScanViewController: QRCodeScanView {
    func update(viewModel__________________ viewModel: QRCodeScanViewModel) { update(with: viewModel)}
}
extension QRCodeScanPresenter {
    func handle(_ event: QRCodeScanPresenterEvent) { handle(event______________________: event) }
}

// MARK: Settings
extension DefaultSettingsLegacyWireframe: SettingsLegacyWireframe {
    func navigate(destination___________ destination: SettingsLegacyWireframeDestination) { navigate(to: destination) }
}
extension SettingsLegacyViewController: SettingsLegacyView {
    func update(viewModel____________ viewModel: SettingsLegacyViewModel) { update(with: viewModel)}
}
extension SettingsLegacyPresenter {
    func handle(_ event: SettingsLegacyPresenterEvent) { handle(event________________:event)}
}

extension DefaultSettingsWireframe: SettingsWireframe {
    func navigate(destination________ destination: SettingsWireframeDestination) { navigate(to: destination) }
}
extension SettingsViewController: SettingsView {
    func update(viewModel_________ viewModel: CollectionViewModel.Screen) { update(with: viewModel)}
}
extension SettingsPresenter {
    func handle(_ event: SettingsPresenterEvent) { handle(event_____________: event)}
}
