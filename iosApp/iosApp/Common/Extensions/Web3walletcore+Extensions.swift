// Created by web3d4v on 16/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: Account
extension DefaultAccountWireframe: AccountWireframe {
    func navigate(destination: AccountWireframeDestination) { navigate(to: destination) }
}
extension AccountViewController: AccountView {
    func update(viewModel: AccountViewModel) { update(with: viewModel) }
}
extension AccountPresenter {
    func handleEvent(_ event: AccountPresenterEvent) { handle(event____: event)  }
}

// MARK: Alert
extension DefaultAlertWireframe: AlertWireframe {
    func navigate(destination___ destination: AlertWireframeDestination) { navigate(to: destination) }
}
extension AlertViewController: AlertView {
    func update(viewModel__ viewModel: AlertViewModelOld) { update(with: viewModel) }
}
extension AlertPresenter {
    func handleEvent(_ event: AlertPresenterEvent) { handle(event_______: event) }
}

// MARK: Authenticate
extension DefaultAuthenticateWireframe: AuthenticateWireframe {
    func navigate(destination____ destination: AuthenticateWireframeDestination) { navigate(to: destination) }
}
extension AuthenticateViewController: AuthenticateView {
    func update(viewModel___ viewModel: AuthenticateViewModel) { update(with: viewModel) }
}
extension AuthenticatePresenter {
    func handleEvent(_ event: AuthenticatePresenterEvent) { handle(event________: event) }
}

// MARK: Confirmation
extension DefaultConfirmationWireframe: ConfirmationWireframe {
    func navigate(destination_____ destination: ConfirmationWireframeDestination) { navigate(to: destination) }
}
extension ConfirmationViewController: ConfirmationView {
    func update(viewModel____ viewModel: ConfirmationViewModel) { update(with: viewModel) }
}
extension ConfirmationPresenter {
    func handleEvent(_ event: ConfirmationPresenterEvent) { handle(event_________: event) }
}

// MARK: CurrencyAdd
extension DefaultCurrencyAddWireframe: CurrencyAddWireframe {
    func navigate(destination______ destination: CurrencyAddWireframeDestination) { navigate(to: destination) }
}
extension CurrencyAddViewController: CurrencyAddView {
    func update(viewModel_____ viewModel: CurrencyAddViewModel) { update(with: viewModel) }
}
extension CurrencyAddPresenter {
    func handleEvent(_ event: CurrencyAddPresenterEvent) { handle(event__________: event) }
}

// MARK: CurrencyPicker
extension DefaultCurrencyPickerWireframe: CurrencyPickerWireframe {
    func navigate(destination_______ destination: CurrencyPickerWireframeDestination) { navigate(to: destination) }
}
extension CurrencyPickerViewController: CurrencyPickerView {
    func update(viewModel______ viewModel: CurrencyPickerViewModel) { update(with: viewModel) }
}
extension CurrencyPickerPresenter {
    func handleEvent(_ event: CurrencyPickerPresenterEvent) { handle(event___________: event) }
}

// MARK: CurrencyReceive
extension DefaultCurrencyReceiveWireframe: CurrencyReceiveWireframe {
    func navigate(destination________ destination: CurrencyReceiveWireframeDestination) { navigate(to: destination) }
}
extension CurrencyReceiveViewController: CurrencyReceiveView {
    func update(viewModel_______ viewModel: CurrencyReceiveViewModel) { update(with: viewModel) }
}
extension CurrencyReceivePresenter {
    func handleEvent(_ event: CurrencyReceivePresenterEvent) { handle(event____________: event) }
}

// MARK: CurrencySend
extension DefaultCurrencySendWireframe: CurrencySendWireframe {
    func navigate(destination_________ destination: CurrencySendWireframeDestination) { navigate(to: destination) }
}
extension CurrencySendViewController: CurrencySendView {
    func update(viewModel________ viewModel: CurrencySendViewModel) { update(with: viewModel) }
}
extension CurrencySendPresenter {
    func handleEvent(_ event: CurrencySendPresenterEvent) { handle(event_____________: event) }
}

// MARK: CurrencySwap
extension DefaultCurrencySwapWireframe: CurrencySwapWireframe {
    func navigate(destination__________ destination: CurrencySwapWireframeDestination) { navigate(to: destination) }
}
extension CurrencySwapViewController: CurrencySwapView {
    func update(viewModel_________ viewModel: CurrencySwapViewModel) { update(with: viewModel) }
}
extension CurrencySwapPresenter {
    func handleEvent(_ event: CurrencySwapPresenterEvent) { handle(event______________: event) }
}

// MARK: Dashboard
extension DefaultDashboardWireframe: DashboardWireframe {
    func navigate(destination___________ destination: DashboardWireframeDestination) { navigate(to: destination) }
}
extension DashboardViewController: DashboardView {
    func update(viewModel__________ viewModel: DashboardViewModel) { update(with: viewModel) }
}
extension DashboardPresenter {
    func handleEvent(_ event: DashboardPresenterEvent) { handle(event________________: event) }
}


// MARK: CultProposal
extension DefaultCultProposalWireframe: CultProposalWireframe {
    func navigate(destination_____________ destination: CultProposalWireframeDestination) { navigate(to: destination) }
}
extension CultProposalViewController: CultProposalView {
    func update(viewModel____________ viewModel: CultProposalViewModel) { update(with: viewModel) }
}
extension CultProposalPresenter {
    func handleEvent(_ event: CultProposalPresenterEvent) { handle(event__________________: event) }
}

// MARK: CultProposals
extension DefaultCultProposalsWireframe: CultProposalsWireframe {
    func navigate(destination______________ destination: CultProposalsWireframeDestination) { navigate(to: destination) }
}
extension CultProposalsViewController: CultProposalsView {
    func update(viewModel_____________ viewModel: CultProposalsViewModel) { update(with: viewModel) }
}
extension CultProposalsPresenter {
    func handleEvent(_ event: CultProposalsPresenterEvent) { handle(event___________________: event) }
}

// MARK: Degen
extension DefaultDegenWireframe: DegenWireframe {
    func navigate(destination____________ destination: DegenWireframeDestination) { navigate(to: destination) }
}
extension DegenViewController: DegenView {
    func update(viewModel___________ viewModel: DegenViewModel) { update(with: viewModel) }
}
extension DegenPresenter {
    func handleEvent(_ event: DegenPresenterEvent) { handle(event_________________: event) }
}

// MARK: Signers
extension DefaultSignersWireframe: SignersWireframe {
    func navigate(destination_____________________________ destination: SignersWireframeDestination) { navigate(to: destination) }
}
extension SignersViewController: SignersView {
    func update(viewModel_______________________ viewModel: SignersViewModel) { update(with: viewModel) }
    func presentToast(viewModel: ToastViewModel) { presentToast(with: viewModel) }
}
extension SignersPresenter {
    func handleEvent(_ event: SignersPresenterEvent) { handle(event__________________________________: event) }
}

// MARK: MnemonicConfirmation
extension DefaultMnemonicConfirmationWireframe: MnemonicConfirmationWireframe {
    func navigate(destination_________________ destination: MnemonicConfirmationWireframeDestination) { navigate(to: destination) }
}
extension MnemonicConfirmationViewController: MnemonicConfirmationView {
    func update(viewModel: CollectionViewModel.Screen, mnemonicInputViewModel: MnemonicInputViewModel) { update(with: viewModel, mnemonicInputViewModel: mnemonicInputViewModel)}
}
extension MnemonicConfirmationPresenter {
    func handleEvent(_ event: MnemonicConfirmationPresenterEvent) { handle(event______________________: event) }
}

// MARK: MnemonicImport
extension DefaultMnemonicImportWireframe: MnemonicImportWireframe {
    func navigate(destination__________________ destination: MnemonicImportWireframeDestination) { navigate(to: destination) }
}
extension MnemonicImportViewController: MnemonicImportView {
    func update(viewModel: CollectionViewModel.Screen, mnemonicInputViewModel: MnemonicInputViewModel) { update(with: viewModel, mnemonicInputViewModel: mnemonicInputViewModel)}
    func presentAlert(viewModel: AlertViewModel) { presentAlert(with: viewModel) }
    func presentToast(viewModel: ToastViewModel) { presentToast(with: viewModel) }
}
extension MnemonicImportPresenter {
    func handleEvent(_ event: MnemonicImportPresenterEvent) { handle(event_______________________: event) }
}

// MARK: AccountImport
extension DefaultAccountImportWireframe: AccountImportWireframe {
    func navigate(destination_ destination: AccountImportWireframeDestination) { navigate(to: destination) }
}
extension AccountImportViewController: AccountImportView {
    func update(viewModel: CollectionViewModel.Screen, inputViewModel: AccountImportInputViewModel) { update(with: viewModel, inputViewModel: inputViewModel)}
    func presentAlert(viewModel: AlertViewModel) { presentAlert(with: viewModel) }
    func presentToast(viewModel: ToastViewModel) { presentToast(with: viewModel) }
}
extension AccountImportPresenter {
    func handleEvent(_ event: AccountImportPresenterEvent) { handle(event_____: event) }
}

// MARK: MnemonicNew
extension DefaultMnemonicNewWireframe: MnemonicNewWireframe {
    func navigate(destination___________________ destination: MnemonicNewWireframeDestination) { navigate(to: destination) }
}

extension MnemonicNewViewController: MnemonicNewView {    
    func update(viewModel_ viewModel: CollectionViewModel.Screen) { update(with: viewModel) }
    func presentToast(viewModel: ToastViewModel) { presentToast(with: viewModel) }
    func presentAlert(viewModel: AlertViewModel) { presentAlert(with: viewModel) }
}

extension MnemonicNewPresenter {
    func handleEvent(_ event: MnemonicNewPresenterEvent) { handle(event________________________: event) }
}

// MARK: MnemonicUpdate
extension DefaultMnemonicUpdateWireframe: MnemonicUpdateWireframe {
    func navigate(destination____________________ destination: MnemonicUpdateWireframeDestination) { navigate(to: destination) }
}

extension MnemonicUpdateViewController: MnemonicUpdateView {
    func update(viewModel_ viewModel: CollectionViewModel.Screen) { update(with: viewModel) }
    func presentAlert(viewModel: AlertViewModel) { presentAlert(with: viewModel) }
    func presentToast(viewModel: ToastViewModel) { presentToast(with: viewModel) }
}

extension MnemonicUpdatePresenter {
    func handleEvent(_ event: MnemonicUpdatePresenterEvent) { handle(event_________________________: event) }
}

// MARK: AccountUpdate
extension DefaultAccountUpdateWireframe: AccountUpdateWireframe {
    func navigate(destination__ destination: AccountUpdateWireframeDestination) { navigate(to: destination) }
}

extension AccountUpdateViewController: AccountUpdateView {
    func update(viewModel_ viewModel: CollectionViewModel.Screen) { update(with: viewModel) }
    func presentAlert(viewModel: AlertViewModel) { presentAlert(with: viewModel) }
    func presentToast(viewModel: ToastViewModel) { presentToast(with: viewModel) }
}

extension AccountUpdatePresenter {
    func handleEvent(_ event: AccountUpdatePresenterEvent) { handle(event______: event) }
}

// MARK: Networks
extension DefaultNetworksWireframe: NetworksWireframe {
    func navigate(destination_____________________ destination: NetworksWireframeDestination) { navigate(to: destination) }
}
extension NetworksViewController: NetworksView {
    func update(viewModel_________________ viewModel: NetworksViewModel) { update(with: viewModel)}
}
extension NetworksPresenter {
    func handleEvent(_ event: NetworksPresenterEvent) { handle(event___________________________: event) }
}

// MARK: NetworkSettings
extension DefaultNetworkSettingsWireframe: NetworkSettingsWireframe {
    //func navigate(destination__ destination: NetworksSettingsLegacyWireframeDestination) { navigate(to: destination) }
}
extension NetworkSettingsViewController: NetworkSettingsView {
    func update(viewModel________________ viewModel: NetworkSettingsViewModel) { update(with: viewModel)}
}
extension NetworkSettingsPresenter {
    func handleEvent(_ event: NetworkSettingsPresenterEvent) { handle(event__________________________: event) }
}

// MARK: NFTDetail
extension DefaultNFTDetailWireframe: NFTDetailWireframe {
    func navigate(destination______________________ destination: NFTDetailWireframeDestination) { navigate(to: destination) }
}
extension NFTDetailViewController: NFTDetailView {
    func update(viewModel__________________ viewModel: NFTDetailViewModel) { update(with: viewModel)}
}
extension NFTDetailPresenter {
    func handleEvent(_ event: NFTDetailPresenterEvent) { handle(event____________________________: event) }
}

// MARK: NFTsCollection
extension DefaultNFTsCollectionWireframe: NFTsCollectionWireframe {
    func navigate(destination________________________ destination: NFTsCollectionWireframeDestination) { navigate(to: destination) }
}
extension NFTsCollectionViewController: NFTsCollectionView {
    func update(viewModel____________________ viewModel: NFTsCollectionViewModel) { update(with: viewModel)}
}
extension NFTsCollectionPresenter {
    func handleEvent(_ event: NFTsCollectionPresenterEvent) { handle(event______________________________: event) }
}

// MARK: NFTsDashboard
extension DefaultNFTsDashboardWireframe: NFTsDashboardWireframe {
    func navigate(destination_________________________ destination: NFTsDashboardWireframeDestination) { navigate(to: destination) }
}
extension NFTsDashboardViewController: NFTsDashboardView {
    func update(viewModel_____________________ viewModel: NFTsDashboardViewModel) { update(with: viewModel)}
}
extension NFTsDashboardPresenter {
    func handleEvent(_ event: NFTsDashboardPresenterEvent) { handle(event_______________________________: event) }
}

// MARK: NFTSend
extension DefaultNFTSendWireframe: NFTSendWireframe {
    func navigate(destination_______________________ destination: NFTSendWireframeDestination) { navigate(to: destination) }
}
extension NFTSendViewController: NFTSendView {
    func update(viewModel___________________ viewModel: NFTSendViewModel) { update(with: viewModel)}
}
extension NFTSendPresenter {
    func handleEvent(_ event: NFTSendPresenterEvent) { handle(event_____________________________: event) }
}

// MARK: ImprovementProposal
extension DefaultImprovementProposalWireframe: ImprovementProposalWireframe {
    func navigate(destination_______________ destination: ImprovementProposalWireframeDestination) { navigate(to: destination) }
}
extension ImprovementProposalViewController: ImprovementProposalView {
    func update(viewModel______________ viewModel: ImprovementProposalViewModel) { update(with: viewModel)}
}
extension ImprovementProposalPresenter {
    func handleEvent(_ event: ImprovementProposalPresenterEvent) { handle(event____________________: event) }
}

// MARK: ImprovementProposals
extension DefaultImprovementProposalsWireframe: ImprovementProposalsWireframe {
    func navigate(destination________________ destination: ImprovementProposalsWireframeDestination) { navigate(to: destination) }
}
extension ImprovementProposalsViewController: ImprovementProposalsView {
    func update(viewModel_______________ viewModel: ImprovementProposalsViewModel) { update(with: viewModel)}
}
extension ImprovementProposalsPresenter {
    func handleEvent(_ event: ImprovementProposalsPresenterEvent) { handle(event_____________________: event) }
}

// MARK: QRCodeScan
extension DefaultQRCodeScanWireframe: QRCodeScanWireframe {
    func navigate(destination__________________________ destination: QRCodeScanWireframeDestination) { navigate(to: destination) }
}
extension QRCodeScanViewController: QRCodeScanView {
    func update(viewModel______________________ viewModel: QRCodeScanViewModel) { update(with: viewModel)}
}
extension QRCodeScanPresenter {
    func handleEvent(_ event: QRCodeScanPresenterEvent) { handle(event________________________________: event) }
}

// MARK: Settings
extension DefaultSettingsWireframe: SettingsWireframe {
    func navigate(destination____________________________ destination: SettingsWireframeDestination) { navigate(to: destination) }
}
extension SettingsViewController: SettingsView {
    func update(viewModel_ viewModel: CollectionViewModel.Screen) { update(with: viewModel)}
}
extension SettingsPresenter {
    func handleEvent(_ event: SettingsPresenterEvent) { handle(event_________________________________: event)}
}
