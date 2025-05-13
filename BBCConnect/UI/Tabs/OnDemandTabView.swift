//
//  OnDemandTabView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI
import AlertToast

struct OnDemandTabView : View {
	
	@State private var assets = [OnDemand]()
	@State private var error: String?
	@State private var isLoading = true
	@State private var canLoadMore = false
	@State private var page = 0
	
	private let limit = 10
	
	var body: some View {
		NavigationStack {
			List {
				ForEach(self.assets, id: \.info.id) { asset in
					if let url = asset.info.playback_ids?.first?.url {
						MuxLiveStreamView(url: url,
										  title: asset.metadata?.title ?? "Untitled",
										  description: asset.metadata?.description)
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
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)
					.listRowSpacing(0)
					.listRowInsets(EdgeInsets())
				}
				else if let error = self.error {
					Text(error)
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
				else if self.assets.isEmpty {
					Text("No on-demand videos available")
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
				else if self.canLoadMore {
					Button(action: {
						self.loadOnDemand()
					}) {
						Text("Load More")
							.font(.headline)
							.foregroundColor(.primary)
							.frame(maxWidth: .infinity)
							.padding(.vertical, Dimens.verticalPadding)
							.padding(.horizontal, Dimens.horizontalPadding)
					}
					.buttonStyle(.plain)
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)
					.listRowSpacing(0)
					.listRowInsets(EdgeInsets())
				}

				// Extra text for spacing
				Text("")
					.padding(.vertical, Dimens.verticalPadding)
					.frame(maxWidth: .infinity)
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)
					.listRowSpacing(0)
					.listRowInsets(EdgeInsets())
			}
			.listStyle(.plain)
			.scrollContentBackground(.hidden)
			.backgroundIgnoreSafeArea(color: .background)
			.refreshable {
				self.loadOnDemand(reset: true)
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
			.toolbarRole(.editor)
			.navigationTitle("On-Demand")
			.task {
				self.loadOnDemand()
			}
		}
		.tint(.primaryMain)
	}
	
	private func loadOnDemand(reset: Bool = false) {
		if reset {
			self.page = 0
			self.canLoadMore = false
		}
		
		self.isLoading = true
		
		// Load next page
		self.page = self.page + 1
		
		Task {
			let queryParams = [ "page": page, "limit": limit ]
			let result: APIResult<OnDemandAssets> = await APIManager.shared.request(endpoint: .getOnDemand, queryParams: queryParams)
			DispatchQueue.main.async {
				withAnimation {
					if case .success(let assets) = result {
						var filteredAssets = assets.assets?.filter({
							if let isLive = $0.info.is_live {
								!isLive
							}
							else {
								true
							}
						}) ?? []
						
						if assets.page == 1 {
							self.assets = filteredAssets
						}
						else {
							self.assets.append(contentsOf: filteredAssets)
						}
						
						self.canLoadMore = assets.total == self.limit
					}
					else if case .failure(let aPIError) = result {
						self.error = aPIError.localizedDescription
					}
					
					self.isLoading = false
				}
			}
		}
	}
}
