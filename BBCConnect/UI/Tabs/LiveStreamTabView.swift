//
//  LiveStreamTabView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

struct LiveStreamTabView : View {
	
	@State private var livestream: LiveStream?
	@State private var isLoading = false
	
	@State private var isStartingLivestream = false
	@State private var isEndingLiveStream = false
	@State private var error: String?
	
	@State private var livestreamTitle = ""
	@State private var livestreamDescription = ""
	@FocusState private var focusedField: Field?
	
	enum Field {
		case livestreamTitle, livestreamDescription
	}
	
	@ViewBuilder
	private func adminView() -> some View {
		VStack(alignment: .leading, spacing: Dimens.verticalPaddingMd) {
			if let livestream = self.livestream {
				
				HStack(alignment: .top) {
					Text("Stream Key:")
						.foregroundColor(.primary)
						.font(.headline)
					
					Spacer()
					
					Text(livestream.info.stream_key)
						.foregroundColor(.secondary)
						.font(.headline)
						.multilineTextAlignment(.trailing)
				}
				
				HStack(alignment: .top) {
					Text("Ingest Url:")
						.foregroundColor(.primary)
						.font(.headline)
					
					Spacer()
					
					Text("rtmps://global-live.mux.com:443/app")
						.foregroundColor(.secondary)
						.font(.headline)
						.multilineTextAlignment(.trailing)
				}
				
				BButton(style: .primary, text: "End Live Stream", isLoading: self.isEndingLiveStream) {
					self.endLiveStream(livestream: livestream)
				}
				
				if let error = self.error {
					Text(error)
						.font(.callout)
						.foregroundColor(.errorMain)
						.frame(maxWidth: .infinity, alignment: .center)
				}
			}
			else {
				BTextField("Title", text: self.$livestreamTitle)
					.focused(self.$focusedField, equals: .livestreamTitle)
					.submitLabel(.next)
					.onSubmit {
						self.focusedField = .livestreamDescription
					}
				
				BTextField("Description (Optional)", text: self.$livestreamDescription)
					.focused(self.$focusedField, equals: .livestreamTitle)
					.submitLabel(.done)
					.onSubmit {
						self.startLiveStream()
					}
				
				BButton(style: .primary, text: "Start Live Stream", isLoading: self.isStartingLivestream) {
					self.startLiveStream()
				}
				
				if let error = self.error {
					Text(error)
						.font(.callout)
						.foregroundColor(.errorMain)
						.frame(maxWidth: .infinity, alignment: .center)
				}
			}
		}
		.frame(maxWidth: 600)
		.padding(.horizontal, Dimens.horizontalPadding)
	}
	
	var body: some View {
		NavigationStack {
			List {
				if self.isLoading {
					HStack {
						Spacer()
						
						ProgressView()
							.progressViewStyle(CircularProgressViewStyle(tint: Color.primary))
						
						Spacer()
					}
					.padding(.top, Dimens.verticalPadding)
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)
					.listRowSpacing(0)
					.listRowInsets(EdgeInsets())
				}
				else {
					if UserCfg.isAdmin() {
						self.adminView()
							.padding(.vertical, Dimens.verticalPadding)
							.frame(maxWidth: .infinity)
							.listRowSeparator(.hidden)
							.listRowBackground(Color.clear)
							.listRowSpacing(0)
							.listRowInsets(EdgeInsets())
					}
					
					if let livestream = self.livestream, let url = livestream.info.playback_ids.first?.url {
						MuxLiveStreamView(url: url,
										  isLive: true,
										  title: livestream.metadata?.title ?? "Untitled Stream",
										  description: livestream.metadata?.description,
										  listenForStreamStatus: true)
						.padding(.top, Dimens.verticalPadding)
						.padding(.horizontal, Dimens.horizontalPadding)
						.frame(maxWidth: .infinity)
						.listRowSeparator(.hidden)
						.listRowBackground(Color.clear)
						.listRowSpacing(0)
						.listRowInsets(EdgeInsets())
					}
					else {
						Text("No live stream available")
							.font(.headline)
							.foregroundColor(.primary)
							.padding(.vertical, Dimens.verticalPadding)
							.padding(.horizontal, Dimens.horizontalPadding)
							.padding(.top, Dimens.verticalPadding * 2)
							.frame(maxWidth: .infinity)
							.listRowSeparator(.hidden)
							.listRowBackground(Color.clear)
							.listRowSpacing(0)
							.listRowInsets(EdgeInsets())
					}
				}
			}
			.listStyle(.plain)
			.scrollContentBackground(.hidden)
			.backgroundIgnoreSafeArea(color: .background)
			.refreshable {
				self.loadLiveStream()
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
			.toolbarRole(.editor)
			.navigationTitle("Live Stream")
			.task {
				self.loadLiveStream()
			}
		}
		.tint(.primaryMain)
	}
	
	private func loadLiveStream() {
		self.isLoading = true
		
		Task {
			let result = await StreamManager.shared.loadLiveStream()
			DispatchQueue.main.async {
				if case .success(let result) = result {
					self.livestream = result.livestream
				}
				
				withAnimation {
					self.isLoading = false
				}
			}
		}
	}
	
	private func startLiveStream() {
		withAnimation {
			self.isStartingLivestream = true
			self.error = nil
		}
		
		Task {
			let result = await StreamManager.shared.startLiveStream(title: self.livestreamTitle, description: self.livestreamDescription)
			DispatchQueue.main.async {
				if case .success(let result) = result {
					self.livestream = result.livestream
					self.livestreamTitle = ""
					self.livestreamDescription = ""
				}
				else if case .failure(let aPIError) = result {
					withAnimation {
						self.error = aPIError.localizedDescription
					}
				}
				
				withAnimation {
					self.isStartingLivestream = false
				}
			}
		}
	}
	
	private func endLiveStream(livestream: LiveStream) {
		withAnimation {
			self.isEndingLiveStream = true
			self.error = nil
		}
		
		Task {
			let result = await StreamManager.shared.stopLiveStream(livestream.info.id)
			DispatchQueue.main.async {
				if case .success(_) = result {
					self.livestream = nil
				}
				else if case .failure(let aPIError) = result {
					withAnimation {
						self.error = aPIError.localizedDescription
					}
				}
					
				withAnimation {
					self.isEndingLiveStream = false
				}
			}
		}
	}
}
