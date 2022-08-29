// Created by web3d4v on 29/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import MessageUI

final class MailHelper: NSObject {
    
    enum Subject {
        case app
        case beta
        
        var string: String {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
            let versionFormatted = "\(version) (\(build))"
            switch self {
            case .app:
                return Localized("settings.root.feedback.subject", arg: versionFormatted)
            case .beta:
                return Localized("settings.root.feedback.subject.beta", arg: versionFormatted)
            }
        }
    }
    
    func sendMail(
        subject: Subject
    ) {
        guard MFMailComposeViewController.canSendMail() else {
            showAlertNoEmailDetected()
            return
        }
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject(subject.string)
        presentingIn?.present(mail, animated: true)
    }
}

extension MailHelper: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}

private extension MailHelper {
    
    var presentingIn: UIViewController? {
        let sceneHelper = SceneDelegateHelper()
        return sceneHelper.rootVC
    }
    
    func showAlertNoEmailDetected() {
        guard let presentingIn = presentingIn else { return }
        let wireframe: AlertWireframeFactory = ServiceDirectory.assembler.resolve()
        wireframe.makeWireframe(
            presentingIn,
            context: .init(
                title: Localized("alert.email.notDetected.title"),
                media: .image(
                    named: "envelope.open.fill",
                    size: .init(length: 100)
                ),
                message: Localized("alert.email.notDetected.message"),
                actions: [
                    .init(
                        title: Localized("Ok"),
                        type: .primary,
                        action: nil
                    )
                ],
                contentHeight: 300
            )
        ).present()
    }
}
