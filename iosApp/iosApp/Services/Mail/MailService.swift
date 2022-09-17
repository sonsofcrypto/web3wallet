// Created by web3d4v on 29/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import MessageUI

struct MailContext {
    
    let subject: Subject
    let body: String?
    
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
    
    init(
        subject: Subject,
        body: String? = nil
    ) {
        self.subject = subject
        self.body = body
    }
}

protocol MailService {
    func sendMail(context: MailContext)
}

final class DefaultMailService: NSObject, MailService {
    func sendMail(context: MailContext) {
        guard MFMailComposeViewController.canSendMail() else {
            showAlertNoEmailDetected()
            return
        }
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["sonsofcrypto@protonmail.com"])
        mail.setSubject(context.subject.string)
        if let body = context.body {
            mail.setMessageBody(body, isHTML: false)
        }
        presentingIn?.present(mail, animated: true)
    }
}

extension DefaultMailService: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}

private extension DefaultMailService {

    // TODO: Smell
    var presentingIn: UIViewController? {
        return UIApplication.shared.rootVc?.topPresentedViewController
    }
    
    func showAlertNoEmailDetected() {
        guard let presentingIn = presentingIn else { return }
        let wireframe: AlertWireframeFactory = ServiceDirectory.assembler.resolve()
        wireframe.make(
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
                contentHeight: 294
            )
        ).present()
    }
}

private extension UIViewController {
    
    var topPresentedViewController: UIViewController {
        if let presentedViewController = presentedViewController {
            return presentedViewController.topPresentedViewController
        }
        return self
    }
}
