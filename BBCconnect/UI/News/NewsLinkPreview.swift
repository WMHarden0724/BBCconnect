//
//  NewsLinkPreview.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/23/25.
//

import SwiftUI
import LinkPresentation

struct NewsLinkPreview: UIViewRepresentable {
	
	let url: URL
	let maxHeight: CGFloat // Custom height limit
	
	func makeUIView(context: Context) -> LPLinkView {
		let view = LPLinkView()
		fetchMetadata(for: url) { metadata in
			if let metadata = metadata {
				view.metadata = metadata
			}
		}
		
		// Force height constraint
		view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.heightAnchor.constraint(equalToConstant: maxHeight)
		])
		
		return view
	}
	
	func updateUIView(_ uiView: LPLinkView, context: Context) {}
	
	// Fetch website metadata
	private func fetchMetadata(for url: URL, completion: @escaping (LPLinkMetadata?) -> Void) {
		let metadataProvider = LPMetadataProvider()
		metadataProvider.startFetchingMetadata(for: url) { metadata, error in
			DispatchQueue.main.async {
				completion(metadata)
			}
		}
	}
}
