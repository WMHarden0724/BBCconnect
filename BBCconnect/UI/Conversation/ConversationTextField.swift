//
//  ConversationTextField.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/18/25.
//

import SwiftUI

struct ConversationTextField : View {
	
	@Binding var message: String
	let onSubmit: () -> Void
	
	var body: some View {
		HStack(spacing: Dimens.horizontalPadding) {
			HStack {
				TextField("Message", text: self.$message)
					.textInputAutocapitalization(.sentences)
					.textFieldStyle(PlainTextFieldStyle())
					.padding(.horizontal, 12)
					.padding(.vertical, 10)
					.foregroundColor(.primary)
				
				// Send button inside the text field
				if !self.message.isEmpty {
					Button(action: self.onSubmit) {
						Image(systemName: "arrow.up")
							.font(.system(size: 18, weight: .bold))
							.foregroundColor(.white)
							.padding(6)
							.background(Color.blue)
							.clipShape(Circle())
							.padding(.trailing, 4)
					}
					.buttonStyle(.plain)
				}
			}
			.clipShape(Capsule())
			.overlay(
				Capsule()
					.stroke(Color.divider, lineWidth: 1)
			)
		}
	}
}
