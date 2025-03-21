//
//  MailView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/21/25.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
	@Environment(\.presentationMode) var presentationMode
	var recipient: String
	var subject: String
	var body: String

	class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
		var parent: MailView

		init(_ parent: MailView) {
			self.parent = parent
		}

		func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
			controller.dismiss(animated: true)
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	func makeUIViewController(context: Context) -> MFMailComposeViewController {
		let mailComposeViewController = MFMailComposeViewController()
		mailComposeViewController.mailComposeDelegate = context.coordinator
		mailComposeViewController.setToRecipients([recipient])
		mailComposeViewController.setSubject(subject)
		mailComposeViewController.setMessageBody(body, isHTML: false)
		return mailComposeViewController
	}

	func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
