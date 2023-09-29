// Created by web3d4v on 16/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: Account
extension DefaultAccountWireframe: AccountWireframe {
    func navigate(destination____________________ destination: AccountWireframeDestination) { navigate(to: destination) }
}
extension AccountViewController: AccountView {
    func update(viewModel____________________ viewModel: AccountViewModel) { update(with: viewModel) }
}
extension AccountPresenter {
    func handleEvent(_ event: AccountPresenterEvent) { handle(event_________________________: event)  }
}

// MARK: Alert
extension DefaultAlertWireframe: AlertWireframe {
    func navigate(destination___________ destination: AlertWireframeDestination) { navigate(to: destination) }
}
extension AlertViewController: AlertView {
    func update(viewModel____________ viewModel: AlertViewModel) { update(with: viewModel) }
}
extension AlertPresenter {
    func handleEvent(_ event: AlertPresenterEvent) { handle(event________________: event) }
}

// MARK: Authenticate
extension DefaultAuthenticateWireframe: AuthenticateWireframe {
    func navigate(destination__________________________ destination: AuthenticateWireframeDestination) { navigate(to: destination) }
}
extension AuthenticateViewController: AuthenticateView {
    func update(viewModel__________________________ viewModel: AuthenticateViewModel) { update(with: viewModel) }
}
extension AuthenticatePresenter {
    func handleEvent(_ event: AuthenticatePresenterEvent) { handle(event_______________________________: event) }
}

// MARK: Confirmation
extension DefaultConfirmationWireframe: ConfirmationWireframe {
    func navigate(destination__________ destination: ConfirmationWireframeDestination) { navigate(to: destination) }
}
extension ConfirmationViewController: ConfirmationView {
    func update(viewModel___________ viewModel: ConfirmationViewModel) { update(with: viewModel) }
}
extension ConfirmationPresenter {
    func handleEvent(_ event: ConfirmationPresenterEvent) { handle(event_______________: event) }
}

// MARK: CurrencyAdd
extension DefaultCurrencyAddWireframe: CurrencyAddWireframe {
    func navigate(destination_________ destination: CurrencyAddWireframeDestination) { navigate(to: destination) }
}
extension CurrencyAddViewController: CurrencyAddView {
    func update(viewModel__________ viewModel: CurrencyAddViewModel) { update(with: viewModel) }
}
extension CurrencyAddPresenter {
    func handleEvent(_ event: CurrencyAddPresenterEvent) { handle(event______________: event) }
}

// MARK: CurrencyPicker
extension DefaultCurrencyPickerWireframe: CurrencyPickerWireframe {
    func navigate(destination_________________________ destination: CurrencyPickerWireframeDestination) { navigate(to: destination) }
}
extension CurrencyPickerViewController: CurrencyPickerView {
    func update(viewModel_________________________ viewModel: CurrencyPickerViewModel) { update(with: viewModel) }
}
extension CurrencyPickerPresenter {
    func handleEvent(_ event: CurrencyPickerPresenterEvent) { handle(event______________________________: event) }
}

// MARK: CurrencyReceive
extension DefaultCurrencyReceiveWireframe: CurrencyReceiveWireframe {
    func navigate(destination__________________ destination: CurrencyReceiveWireframeDestination) { navigate(to: destination) }
}
extension CurrencyReceiveViewController: CurrencyReceiveView {
    func update(viewModel__________________ viewModel: CurrencyReceiveViewModel) { update(with: viewModel) }
}
extension CurrencyReceivePresenter {
    func handleEvent(_ event: CurrencyReceivePresenterEvent) { handle(event______________________: event) }
}

// MARK: CurrencySend
extension DefaultCurrencySendWireframe: CurrencySendWireframe {
    func navigate(destination_______________ destination: CurrencySendWireframeDestination) { navigate(to: destination) }
}
extension CurrencySendViewController: CurrencySendView {
    func update(viewModel________________ viewModel: CurrencySendViewModel) { update(with: viewModel) }
}
extension CurrencySendPresenter {
    func handleEvent(_ event: CurrencySendPresenterEvent) { handle(event____________________: event) }
}

// MARK: CurrencySwap
extension DefaultCurrencySwapWireframe: CurrencySwapWireframe {
    func navigate(destination________________________ destination: CurrencySwapWireframeDestination) { navigate(to: destination) }
}
extension CurrencySwapViewController: CurrencySwapView {
    func update(viewModel________________________ viewModel: CurrencySwapViewModel) { update(with: viewModel) }
}
extension CurrencySwapPresenter {
    func handleEvent(_ event: CurrencySwapPresenterEvent) { handle(event_____________________________: event) }
}

// MARK: Dashboard
extension DefaultDashboardWireframe: DashboardWireframe {
    func navigate(destination___________________ destination: DashboardWireframeDestination) { navigate(to: destination) }
}
extension DashboardViewController: DashboardView {
    func update(viewModel___________________ viewModel: DashboardViewModel) { update(with: viewModel) }
}
extension DashboardPresenter {
    func handleEvent(_ event: DashboardPresenterEvent) { handle(event________________________: event) }
}


// MARK: CultProposal
extension DefaultCultProposalWireframe: CultProposalWireframe {
    func navigate(destination_ destination: CultProposalWireframeDestination) { navigate(to: destination) }
}
extension CultProposalViewController: CultProposalView {
    func update(viewModel_ viewModel: CultProposalViewModel) { update(with: viewModel) }
}
extension CultProposalPresenter {
    func handleEvent(_ event: CultProposalPresenterEvent) { handle(event_____: event) }
}

// MARK: CultProposals
extension DefaultCultProposalsWireframe: CultProposalsWireframe {
    func navigate(destination______ destination: CultProposalsWireframeDestination) { navigate(to: destination) }
}
extension CultProposalsViewController: CultProposalsView {
    func update(viewModel______ viewModel: CultProposalsViewModel) { update(with: viewModel) }
}
extension CultProposalsPresenter {
    func handleEvent(_ event: CultProposalsPresenterEvent) { handle(event__________: event) }
}

// MARK: Degen
extension DefaultDegenWireframe: DegenWireframe {
    func navigate(destination______________ destination: DegenWireframeDestination) { navigate(to: destination) }
}
extension DegenViewController: DegenView {
    func update(viewModel_______________ viewModel: DegenViewModel) { update(with: viewModel) }
}
extension DegenPresenter {
    func handleEvent(_ event: DegenPresenterEvent) { handle(event___________________: event) }
}

// MARK: KeyStore
extension DefaultKeyStoreWireframe: KeyStoreWireframe {
    func navigate(destination___ destination: KeyStoreWireframeDestination) { navigate(to: destination) }
}
extension KeyStoreViewController: KeyStoreView {
    func update(viewModel___ viewModel: KeyStoreViewModel) { update(with: viewModel) }
}
extension KeyStorePresenter {
    func handleEvent(_ event: KeyStorePresenterEvent) { handle(event_______: event) }
}

// MARK: MnemonicConfirmation
extension DefaultMnemonicConfirmationWireframe: MnemonicConfirmationWireframe {
    func navigate(destination_____ destination: MnemonicConfirmationWireframeDestination) { navigate(to: destination) }
}
extension MnemonicConfirmationViewController: MnemonicConfirmationView {
    func update(viewModel_____ viewModel: MnemonicConfirmationViewModel) { update(with: viewModel) }
}
extension MnemonicConfirmationPresenter {
    func handleEvent(_ event: MnemonicConfirmationPresenterEvent) { handle(event_________: event) }
}

// MARK: MnemonicImport
extension DefaultMnemonicImportWireframe: MnemonicImportWireframe {
    func navigate(destination___________________________ destination: MnemonicImportWireframeDestination) { navigate(to: destination) }
}
extension MnemonicImportViewController: MnemonicImportView {
    func update(viewModel___________________________ viewModel: MnemonicImportViewModel) { update(with: viewModel) }
}
extension MnemonicImportPresenter {
    func handleEvent(_ event: MnemonicImportPresenterEvent) { handle(event________________________________: event) }
}

// MARK: MnemonicNew
extension DefaultMnemonicNewWireframe: MnemonicNewWireframe {
    func navigate(destination_____________________ destination: MnemonicNewWireframeDestination) { navigate(to: destination) }
}
extension MnemonicNewViewController: MnemonicNewView {
    func update(viewModel_____________________ viewModel: MnemonicNewViewModel) { update(with: viewModel) }
}
extension MnemonicNewPresenter {
    func handleEvent(_ event: MnemonicNewPresenterEvent) { handle(event__________________________: event) }
}

// MARK: MnemonicUpdate
extension DefaultMnemonicUpdateWireframe: MnemonicUpdateWireframe {
    func navigate(destination: MnemonicUpdateWireframeDestination) { navigate(to: destination) }
}
extension MnemonicUpdateViewController: MnemonicUpdateView {
    func update(viewModel: MnemonicUpdateViewModel) { update(with: viewModel) }
}
extension MnemonicUpdatePresenter {
    func handleEvent(_ event: MnemonicUpdatePresenterEvent) { handle(event____: event) }
}

// MARK: Networks
extension DefaultNetworksWireframe: NetworksWireframe {
    func navigate(destination_______________________ destination: NetworksWireframeDestination) { navigate(to: destination) }
}
extension NetworksViewController: NetworksView {
    func update(viewModel_______________________ viewModel: NetworksViewModel) { update(with: viewModel)}
}
extension NetworksPresenter {
    func handleEvent(_ event: NetworksPresenterEvent) { handle(event____________________________: event) }
}

// MARK: NetworkSettings
extension DefaultNetworkSettingsWireframe: NetworkSettingsWireframe {
    //func navigate(destination__ destination: NetworksSettingsLegacyWireframeDestination) { navigate(to: destination) }
}
extension NetworkSettingsViewController: NetworkSettingsView {
    func update(viewModel_______ viewModel: NetworkSettingsViewModel) { update(with: viewModel)}
}
extension NetworkSettingsPresenter {
    func handleEvent(_ event: NetworkSettingsPresenterEvent) { handle(event___________: event) }
}

// MARK: NFTDetail
extension DefaultNFTDetailWireframe: NFTDetailWireframe {
    func navigate(destination____ destination: NFTDetailWireframeDestination) { navigate(to: destination) }
}
extension NFTDetailViewController: NFTDetailView {
    func update(viewModel____ viewModel: NFTDetailViewModel) { update(with: viewModel)}
}
extension NFTDetailPresenter {
    func handleEvent(_ event: NFTDetailPresenterEvent) { handle(event________: event) }
}

// MARK: NFTsCollection
extension DefaultNFTsCollectionWireframe: NFTsCollectionWireframe {
    func navigate(destination__ destination: NFTsCollectionWireframeDestination) { navigate(to: destination) }
}
extension NFTsCollectionViewController: NFTsCollectionView {
    func update(viewModel__ viewModel: NFTsCollectionViewModel) { update(with: viewModel)}
}
extension NFTsCollectionPresenter {
    func handleEvent(_ event: NFTsCollectionPresenterEvent) { handle(event______: event) }
}

// MARK: NFTsDashboard
extension DefaultNFTsDashboardWireframe: NFTsDashboardWireframe {
    func navigate(destination____________ destination: NFTsDashboardWireframeDestination) { navigate(to: destination) }
}
extension NFTsDashboardViewController: NFTsDashboardView {
    func update(viewModel_____________ viewModel: NFTsDashboardViewModel) { update(with: viewModel)}
}
extension NFTsDashboardPresenter {
    func handleEvent(_ event: NFTsDashboardPresenterEvent) { handle(event_________________: event) }
}

// MARK: NFTSend
extension DefaultNFTSendWireframe: NFTSendWireframe {
    func navigate(destination______________________ destination: NFTSendWireframeDestination) { navigate(to: destination) }
}
extension NFTSendViewController: NFTSendView {
    func update(viewModel______________________ viewModel: NFTSendViewModel) { update(with: viewModel)}
}
extension NFTSendPresenter {
    func handleEvent(_ event: NFTSendPresenterEvent) { handle(event___________________________: event) }
}

// MARK: ImprovementProposal
extension DefaultImprovementProposalWireframe: ImprovementProposalWireframe {
    func navigate(destination_____________ destination: ImprovementProposalWireframeDestination) { navigate(to: destination) }
}
extension ImprovementProposalViewController: ImprovementProposalView {
    func update(viewModel______________ viewModel: ImprovementProposalViewModel) { update(with: viewModel)}
}
extension ImprovementProposalPresenter {
    func handleEvent(_ event: ImprovementProposalPresenterEvent) { handle(event__________________: event) }
}

// MARK: ImprovementProposals
extension DefaultImprovementProposalsWireframe: ImprovementProposalsWireframe {
    func navigate(destination_______ destination: ImprovementProposalsWireframeDestination) { navigate(to: destination) }
}
extension ImprovementProposalsViewController: ImprovementProposalsView {
    func update(viewModel________ viewModel: ImprovementProposalsViewModel) { update(with: viewModel)}
}
extension ImprovementProposalsPresenter {
    func handleEvent(_ event: ImprovementProposalsPresenterEvent) { handle(event____________: event) }
}

// MARK: QRCodeScan
extension DefaultQRCodeScanWireframe: QRCodeScanWireframe {
    func navigate(destination________________ destination: QRCodeScanWireframeDestination) { navigate(to: destination) }
}
extension QRCodeScanViewController: QRCodeScanView {
    func update(viewModel_________________ viewModel: QRCodeScanViewModel) { update(with: viewModel)}
}
extension QRCodeScanPresenter {
    func handleEvent(_ event: QRCodeScanPresenterEvent) { handle(event_____________________: event) }
}

// MARK: Settings
extension DefaultSettingsWireframe: SettingsWireframe {
    func navigate(destination________ destination: SettingsWireframeDestination) { navigate(to: destination) }
}
extension SettingsViewController: SettingsView {
    func update(viewModel_________ viewModel: CollectionViewModel.Screen) { update(with: viewModel)}
}
extension SettingsPresenter {
    func handleEvent(_ event: SettingsPresenterEvent) { handle(event_____________: event)}
}
