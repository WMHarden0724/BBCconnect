//
//  FacebookLiveView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/30/25.
//

import SwiftUI
import WebKit

struct FacebookLiveView: UIViewRepresentable {
	private let url: URL = URL(string: "https://www.facebook.com/{user_id}/videos/{video_id}/")!
	
	func makeUIView(context: Context) -> WKWebView {
		let webView = WKWebView()
		return webView
	}
	
	func updateUIView(_ webView: WKWebView, context: Context) {
		let request = URLRequest(url: url)
		webView.load(request)
	}
}
