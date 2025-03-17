//
//  EmailView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation
import SwiftUI
import MessageUI

struct EmailView: UIViewControllerRepresentable {
	@Binding var isPresented: Bool
	var recipient: String
	var subject: String
	var body: String
	
	class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
		var parent: EmailView
		
		init(parent: EmailView) {
			self.parent = parent
		}
		
		func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
			self.parent.isPresented = false
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(parent: self)
	}
	
	func makeUIViewController(context: Context) -> MFMailComposeViewController {
		let mailVC = MFMailComposeViewController()
		mailVC.mailComposeDelegate = context.coordinator
		mailVC.setToRecipients([self.recipient])
		mailVC.setSubject(self.subject)
		mailVC.setMessageBody(self.body, isHTML: false)
		return mailVC
	}
	
	func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
