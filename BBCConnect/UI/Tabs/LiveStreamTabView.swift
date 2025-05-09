//
//  LiveStreamTabView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

struct LiveStreamTabView : View {
	
	@State private var myLivestream: LiveStream?
	@State private var livestreams = [LiveStream]()
	@State private var isLoading = false
	
	@State private var isStartingLivestream = false
	@State private var isEndingLiveStream = false
	@State private var error: String?
	
	@State private var livestreamTitle = ""
	@State private var livestreamDescription = ""
	@FocusState private var focusedField: Field?
	
	@State private var showIngestUrl = false
	@State private var showErrorAlert = false
	
	enum Field {
		case livestreamTitle, livestreamDescription
	}
	
	@ViewBuilder
	private func adminView() -> some View {
		VStack(alignment: .leading, spacing: Dimens.verticalPaddingMd) {
			Text("Live Stream Info")
				.foregroundColor(self.myLivestream == nil ? .primary : .secondary)
				.font(.headline)
			
			BTextField("Title", text: self.$livestreamTitle)
				.focused(self.$focusedField, equals: .livestreamTitle)
				.submitLabel(.next)
				.disabled(self.myLivestream != nil)
				.onSubmit {
					self.focusedField = .livestreamDescription
				}
			
			BTextField("Description (Optional)", text: self.$livestreamDescription)
				.focused(self.$focusedField, equals: .livestreamTitle)
				.submitLabel(.done)
				.disabled(self.myLivestream != nil)
				.onSubmit {
					self.startLiveStream()
				}
		}
		.frame(maxWidth: 600)
		.padding(.horizontal, Dimens.horizontalPadding)
		.alert("Error", isPresented: self.$showErrorAlert) {
			Button("Ok", role: .cancel) { }
		} message: {
			Text(self.error ?? "")
		}
	}
	
	var body: some View {
		NavigationStack {
			List {
				if UserCfg.isAdmin() {
					self.adminView()
						.padding(.vertical, Dimens.verticalPadding)
						.frame(maxWidth: .infinity)
						.listRowSeparator(.hidden)
						.listRowBackground(Color.clear)
						.listRowSpacing(0)
						.listRowInsets(EdgeInsets())
					
					Divider()
						.listRowSeparator(.hidden)
						.listRowBackground(Color.clear)
						.listRowSpacing(0)
						.listRowInsets(EdgeInsets())
				}
				
				if let livestream = self.myLivestream, let url = livestream.info.playback_ids.first?.url {
					MuxLiveStreamView(url: url,
									  isLive: true,
									  title: livestream.metadata?.title ?? "Untitled Stream",
									  description: livestream.metadata?.description,
									  streamKey: livestream.info.stream_key)
					.padding(.top, Dimens.verticalPadding)
					.padding(.horizontal, Dimens.horizontalPadding)
					.frame(maxWidth: .infinity)
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)
					.listRowSpacing(0)
					.listRowInsets(EdgeInsets())
				}
				
				ForEach(self.livestreams, id: \.info.id) { livestream in
					if let url = livestream.info.playback_ids.first?.url {
						MuxLiveStreamView(url: url,
										  isLive: true,
										  title: livestream.metadata?.title ?? "Untitled Stream",
										  description: livestream.metadata?.description,
										  streamKey: livestream.info.stream_key)
						.padding(.top, Dimens.verticalPadding)
						.padding(.horizontal, Dimens.horizontalPadding)
						.frame(maxWidth: .infinity)
						.listRowSeparator(.hidden)
						.listRowBackground(Color.clear)
						.listRowSpacing(0)
						.listRowInsets(EdgeInsets())
					}
				}
				
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
				else if self.livestreams.isEmpty && self.myLivestream == nil {
					Text("No live streams available")
						.font(.headline)
						.foregroundColor(.primary)
						.padding(.vertical, Dimens.verticalPadding)
						.padding(.horizontal, Dimens.horizontalPadding)
						.padding(.top, Dimens.verticalPadding)
						.frame(maxWidth: .infinity)
						.listRowSeparator(.hidden)
						.listRowBackground(Color.clear)
						.listRowSpacing(0)
						.listRowInsets(EdgeInsets())
				}
			}
			.listStyle(.plain)
			.scrollContentBackground(.hidden)
			.backgroundIgnoreSafeArea(color: .background)
			.refreshable {
				self.loadLiveStreams()
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
			.toolbarRole(.editor)
			.navigationTitle("Live Stream")
			.toolbar {
				if UserCfg.isAdmin() {
					ToolbarItem(placement: .navigationBarLeading) {
						Button(action: {
							self.showIngestUrl = true
						}) {
							Image(systemName: "info.circle")
								.imageScale(.large)
								.foregroundColor(.primaryMain)
						}
					}
					
					ToolbarItem(placement: .navigationBarTrailing) {
						ZStack {
							Button(action: {
								if let livestream = self.myLivestream {
									self.endLiveStream(livestream: livestream)
								}
								else {
									self.startLiveStream()
								}
							}) {
								Text(self.myLivestream != nil ? "End Live" : "Go Live")
									.foregroundColor(.primaryMain)
									.font(.headline)
							}
							.disabled(self.isStartingLivestream || self.isEndingLiveStream)
							.opacity(self.isStartingLivestream || self.isEndingLiveStream ? 0 : 1)
							
							if self.isStartingLivestream || self.isEndingLiveStream {
								ProgressView()
									.foregroundColor(.primaryMain)
							}
						}
						.animation(.easeInOut, value: self.myLivestream)
						.animation(.easeInOut, value: self.isStartingLivestream)
						.animation(.easeInOut, value: self.isEndingLiveStream)
					}
				}
			}
			.alert("Ingest Url", isPresented: self.$showIngestUrl) {
				Button("Ok", role: .cancel) { }
			} message: {
				Text("rtmps://global-live.mux.com:443/app")
			}
			.task {
				self.loadLiveStreams()
			}
		}
		.tint(.primaryMain)
	}
	
	private func loadLiveStreams() {
		self.isLoading = true
		
		Task {
			let result = await StreamManager.shared.loadLiveStreams()
			DispatchQueue.main.async {
				if case .success(let result) = result {
					self.livestreams = result.livestreams?.filter({ $0.info.id != self.myLivestream?.info.id }) ?? []
				}
				
				withAnimation {
					self.isLoading = false
				}
			}
		}
	}
	
	private func startLiveStream() {
		self.isStartingLivestream = true
		
		Task {
			let result = await StreamManager.shared.startLiveStream(title: self.livestreamTitle, description: self.livestreamDescription)
			DispatchQueue.main.async {
				if case .success(let result) = result {
					self.myLivestream = result.livestream
					self.livestreamTitle = ""
					self.livestreamDescription = ""
				}
				else if case .failure(let aPIError) = result {
					self.error = aPIError.localizedDescription
					self.showErrorAlert = true
				}
				
				withAnimation {
					self.isStartingLivestream = false
				}
			}
		}
	}
	
	private func endLiveStream(livestream: LiveStream) {
		self.isEndingLiveStream = true
		
		Task {
			let result = await StreamManager.shared.stopLiveStream(livestream.info.id)
			DispatchQueue.main.async {
				if case .success(_) = result {
					self.myLivestream = nil
				}
				else if case .failure(let aPIError) = result {
					self.error = aPIError.localizedDescription
					self.showErrorAlert = true
				}
					
				withAnimation {
					self.isEndingLiveStream = false
				}
			}
		}
	}
}
