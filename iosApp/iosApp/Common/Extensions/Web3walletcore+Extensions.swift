// Created by web3d4v on 16/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: Account
extension DefaultAccountWireframe: AccountWireframe {
    func navigate(destination___________________ destination: AccountWireframeDestination) { navigate(with: destination) }
}
extension AccountViewController: AccountView {
    func update(viewModel___________________ viewModel: AccountViewModel) { update(with: viewModel) }
}
extension AccountPresenter {
    func handle(event: AccountPresenterEvent) { handle(event________________________: event)  }
}

// MARK: Alert
extension DefaultAlertWireframe: AlertWireframe {
    func navigate(destination__________ destination: AlertWireframeDestination) { navigate(with: destination) }
}
extension AlertViewController: AlertView {
    func update(viewModel___________ viewModel: AlertViewModel) { update(with: viewModel) }
}
extension AlertPresenter {
    func handle(event: AlertPresenterEvent) { handle(event_______________: event) }
}

// MARK: Authenticate
extension DefaultAuthenticateWireframe: AuthenticateWireframe {
    func navigate(destination_________________________ destination: AuthenticateWireframeDestination) { navigate(with: destination) }
}
extension AuthenticateViewController: AuthenticateView {
    func update(viewModel_________________________ viewModel: AuthenticateViewModel) { update(with: viewModel) }
}
extension AuthenticatePresenter {
    func handle(event: AuthenticatePresenterEvent) { handle(event______________________________: event) }
}

// MARK: Confirmation
extension DefaultConfirmationWireframe: ConfirmationWireframe {
    func navigate(destination________ destination: ConfirmationWireframeDestination) { navigate(with: destination) }
}
extension ConfirmationViewController: ConfirmationView {
    func update(viewModel_________ viewModel: ConfirmationViewModel) { update(with: viewModel) }
}
extension ConfirmationPresenter {
    func handle(event: ConfirmationPresenterEvent) { handle(event_____________: event) }
}

// MARK: CurrencyAdd
extension DefaultCurrencyAddWireframe: CurrencyAddWireframe {
    func navigate(destination_________ destination: CurrencyAddWireframeDestination) { navigate(with: destination) }
}
extension CurrencyAddViewController: CurrencyAddView {
    func update(viewModel__________ viewModel: CurrencyAddViewModel) { update(with: viewModel) }
}
extension CurrencyAddPresenter {
    func handle(event: CurrencyAddPresenterEvent) { handle(event______________: event) }
}

// MARK: CurrencyPicker
extension DefaultCurrencyPickerWireframe: CurrencyPickerWireframe {
    func navigate(destination________________________ destination: CurrencyPickerWireframeDestination) { navigate(with: destination) }
}
extension CurrencyPickerViewController: CurrencyPickerView {
    func update(viewModel________________________ viewModel: CurrencyPickerViewModel) { update(with: viewModel) }
}
extension CurrencyPickerPresenter {
    func handle(event: CurrencyPickerPresenterEvent) { handle(event_____________________________: event) }
}

// MARK: CurrencyReceive
extension DefaultCurrencyReceiveWireframe: CurrencyReceiveWireframe {
    func navigate(destination_________________ destination: CurrencyReceiveWireframeDestination) { navigate(with: destination) }
}
extension CurrencyReceiveViewController: CurrencyReceiveView {
    func update(viewModel_________________ viewModel: CurrencyReceiveViewModel) { update(with: viewModel) }
}
extension CurrencyReceivePresenter {
    func handle(event: CurrencyReceivePresenterEvent) { handle(event_____________________: event) }
}

// MARK: CurrencySend
extension DefaultCurrencySendWireframe: CurrencySendWireframe {
    func navigate(destination______________ destination: CurrencySendWireframeDestination) { navigate(with: destination) }
}
extension CurrencySendViewController: CurrencySendView {
    func update(viewModel_______________ viewModel: CurrencySendViewModel) { update(with: viewModel) }
}
extension CurrencySendPresenter {
    func handle(event: CurrencySendPresenterEvent) { handle(event___________________: event) }
}

// MARK: CurrencySwap
extension DefaultCurrencySwapWireframe: CurrencySwapWireframe {
    func navigate(destination_______________________ destination: CurrencySwapWireframeDestination) { navigate(with: destination) }
}
extension CurrencySwapViewController: CurrencySwapView {
    func update(viewModel_______________________ viewModel: CurrencySwapViewModel) { update(with: viewModel) }
}
extension CurrencySwapPresenter {
    func handle(event: CurrencySwapPresenterEvent) { handle(event____________________________: event) }
}

// MARK: Dashboard
extension DefaultDashboardWireframe: DashboardWireframe {
    func navigate(destination__________________ destination: DashboardWireframeDestination) { navigate(with: destination) }
}
extension DashboardViewController: DashboardView {
    func update(viewModel__________________ viewModel: DashboardViewModel) { update(with: viewModel) }
}
extension DashboardPresenter {
    func handle(event: DashboardPresenterEvent) { handle(event_______________________: event) }
}


// MARK: CultProposal
extension DefaultCultProposalWireframe: CultProposalWireframe {
    func navigate(destination_ destination: CultProposalWireframeDestination) { navigate(with: destination) }
}
extension CultProposalViewController: CultProposalView {
    func update(viewModel_ viewModel: CultProposalViewModel) { update(with: viewModel) }
}
extension CultProposalPresenter {
    func handle(event: CultProposalPresenterEvent) { handle(event_____: event) }
}

// MARK: CultProposals
extension DefaultCultProposalsWireframe: CultProposalsWireframe {
    func navigate(destination______ destination: CultProposalsWireframeDestination) { navigate(with: destination) }
}
extension CultProposalsViewController: CultProposalsView {
    func update(viewModel______ viewModel: CultProposalsViewModel) { update(with: viewModel) }
}
extension CultProposalsPresenter {
    func handle(event: CultProposalsPresenterEvent) { handle(event__________: event) }
}

// MARK: Degen
extension DefaultDegenWireframe: DegenWireframe {
    func navigate(destination____________ destination: DegenWireframeDestination) { navigate(with: destination) }
}
extension DegenViewController: DegenView {
    func update(viewModel_____________ viewModel: DegenViewModel) { update(with: viewModel) }
}
extension DegenPresenter {
    func handle(event: DegenPresenterEvent) { handle(event_________________: event) }
}

// MARK: KeyStore
extension DefaultKeyStoreWireframe: KeyStoreWireframe {
    func navigate(destination___ destination: KeyStoreWireframeDestination) { navigate(with: destination) }
}
extension KeyStoreViewController: KeyStoreView {
    func update(viewModel___ viewModel: KeyStoreViewModel) { update(with: viewModel) }
}
extension KeyStorePresenter {
    func handle(event: KeyStorePresenterEvent) { handle(event_______: event) }
}

// MARK: MnemonicConfirmation
extension DefaultMnemonicConfirmationWireframe: MnemonicConfirmationWireframe {
    func navigate(destination_____ destination: MnemonicConfirmationWireframeDestination) { navigate(with: destination) }
}
extension MnemonicConfirmationViewController: MnemonicConfirmationView {
    func update(viewModel_____ viewModel: MnemonicConfirmationViewModel) { update(with: viewModel) }
}
extension MnemonicConfirmationPresenter {
    func handle(event: MnemonicConfirmationPresenterEvent) { handle(event_________: event) }
}

// MARK: MnemonicImport
extension DefaultMnemonicImportWireframe: MnemonicImportWireframe {
    func navigate(destination__________________________ destination: MnemonicImportWireframeDestination) { navigate(with: destination) }
}
extension MnemonicImportViewController: MnemonicImportView {
    func update(viewModel__________________________ viewModel: MnemonicImportViewModel) { update(with: viewModel) }
}
extension MnemonicImportPresenter {
    func handle(event: MnemonicImportPresenterEvent) { handle(event_______________________________: event) }
}

// MARK: MnemonicNew
extension DefaultMnemonicNewWireframe: MnemonicNewWireframe {
    func navigate(destination____________________ destination: MnemonicNewWireframeDestination) { navigate(with: destination) }
}
extension MnemonicNewViewController: MnemonicNewView {
    func update(viewModel____________________ viewModel: MnemonicNewViewModel) { update(with: viewModel) }
}
extension MnemonicNewPresenter {
    func handle(event: MnemonicNewPresenterEvent) { handle(event_________________________: event) }
}

// MARK: MnemonicUpdate
extension DefaultMnemonicUpdateWireframe: MnemonicUpdateWireframe {
    func navigate(destination: MnemonicUpdateWireframeDestination) { navigate(with: destination) }
}
extension MnemonicUpdateViewController: MnemonicUpdateView {
    func update(viewModel: MnemonicUpdateViewModel) { update(with: viewModel) }
}
extension MnemonicUpdatePresenter {
    func handle(event: MnemonicUpdatePresenterEvent) { handle(event____: event) }
}

// MARK: Networks
extension DefaultNetworksWireframe: NetworksWireframe {
    func navigate(destination______________________ destination: NetworksWireframeDestination) { navigate(with: destination) }
}
extension NetworksViewController: NetworksView {
    func update(viewModel______________________ viewModel: NetworksViewModel) { update(with: viewModel)}
}
extension NetworksPresenter {
    func handle(event: NetworksPresenterEvent) { handle(event___________________________: event) }
}

// MARK: NetworkSettings
extension DefaultNetworkSettingsWireframe: NetworkSettingsWireframe {
    //func navigate(destination__ destination: NetworksSettingsWireframeDestination) { navigate(with: destination) }
}
extension NetworkSettingsViewController: NetworkSettingsView {
    func update(viewModel_______ viewModel: NetworkSettingsViewModel) { update(with: viewModel)}
}
extension NetworkSettingsPresenter {
    func handle(event: NetworkSettingsPresenterEvent) { handle(event___________: event) }
}

// MARK: NFTDetail
extension DefaultNFTDetailWireframe: NFTDetailWireframe {
    func navigate(destination____ destination: NFTDetailWireframeDestination) { navigate(with: destination) }
}
extension NFTDetailViewController: NFTDetailView {
    func update(viewModel____ viewModel: NFTDetailViewModel) { update(with: viewModel)}
}
extension NFTDetailPresenter {
    func handle(event: NFTDetailPresenterEvent) { handle(event________: event) }
}

// MARK: NFTsCollection
extension DefaultNFTsCollectionWireframe: NFTsCollectionWireframe {
    func navigate(destination__ destination: NFTsCollectionWireframeDestination) { navigate(with: destination) }
}
extension NFTsCollectionViewController: NFTsCollectionView {
    func update(viewModel__ viewModel: NFTsCollectionViewModel) { update(with: viewModel)}
}
extension NFTsCollectionPresenter {
    func handle(event: NFTsCollectionPresenterEvent) { handle(event______: event) }
}

// MARK: NFTsDashboard
extension DefaultNFTsDashboardWireframe: NFTsDashboardWireframe {
    func navigate(destination___________ destination: NFTsDashboardWireframeDestination) { navigate(with: destination) }
}
extension NFTsDashboardViewController: NFTsDashboardView {
    func update(viewModel____________ viewModel: NFTsDashboardViewModel) { update(with: viewModel)}
}
extension NFTsDashboardPresenter {
    func handle(event: NFTsDashboardPresenterEvent) { handle(event________________: event) }
}

// MARK: NFTSend
extension DefaultNFTSendWireframe: NFTSendWireframe {
    func navigate(destination_____________________ destination: NFTSendWireframeDestination) { navigate(with: destination) }
}
extension NFTSendViewController: NFTSendView {
    func update(viewModel_____________________ viewModel: NFTSendViewModel) { update(with: viewModel)}
}
extension NFTSendPresenter {
    func handle(event: NFTSendPresenterEvent) { handle(event__________________________: event) }
}

// MARK: ImprovementProposal
extension DefaultImprovementProposalWireframe: ImprovementProposalWireframe {
    func navigate(destination_____________ destination: ImprovementProposalWireframeDestination) { navigate(with: destination) }
}
extension ImprovementProposalViewController: ImprovementProposalView {
    func update(viewModel______________ viewModel: ImprovementProposalViewModel) { update(with: viewModel)}
}
extension ImprovementProposalPresenter {
    func handle(event: ImprovementProposalPresenterEvent) { handle(event__________________: event) }
}

// MARK: ImprovementProposals
extension DefaultImprovementProposalsWireframe: ImprovementProposalsWireframe {
    func navigate(destination_______ destination: ImprovementProposalsWireframeDestination) { navigate(with: destination) }
}
extension ImprovementProposalsViewController: ImprovementProposalsView {
    func update(viewModel________ viewModel: ImprovementProposalsViewModel) { update(with: viewModel)}
}
extension ImprovementProposalsPresenter {
    func handle(event: ImprovementProposalsPresenterEvent) { handle(event____________: event) }
}

// MARK: QRCodeScan
extension DefaultQRCodeScanWireframe: QRCodeScanWireframe {
    func navigate(destination_______________ destination: QRCodeScanWireframeDestination) { navigate(with: destination) }
}
extension QRCodeScanViewController: QRCodeScanView {
    func update(viewModel________________ viewModel: QRCodeScanViewModel) { update(with: viewModel)}
}
extension QRCodeScanPresenter {
    func handle(event: QRCodeScanPresenterEvent) { handle(event____________________: event) }
}
