//
//  BTextField.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/28/25.
//

import SwiftUI

struct BTextField : View {
	
	let placeholder: String
	@Binding var text: String
	
	init(_ placeholder: String, text: Binding<String>) {
		self.placeholder = placeholder
		_text = text
	}
	
	var body: some View {
		TextField(self.placeholder, text: self.$text)
			.foregroundColor(.primary)
			.textFieldStyle(PlainTextFieldStyle())
			.padding(.horizontal, 12)
			.padding(.vertical, 12)
			.foregroundColor(.primary)
			.overlay(
				Capsule()
					.stroke(Color.divider, lineWidth: 1)
			)
	}
}

struct BSecureField : View {
	
	let placeholder: String
	@Binding var text: String
	
	init(_ placeholder: String, text: Binding<String>) {
		self.placeholder = placeholder
		_text = text
	}
	
	var body: some View {
		SecureField(self.placeholder, text: self.$text)
			.textFieldStyle(PlainTextFieldStyle())
			.padding(.horizontal, 12)
			.padding(.vertical, 12)
			.foregroundColor(.primary)
			.overlay(
				Capsule()
					.stroke(Color.divider, lineWidth: 1)
			)
	}
}
