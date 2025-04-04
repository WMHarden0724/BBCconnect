//
//  BulletinListItem.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/23/25.
//

import SwiftUI

struct BulletinListItem : View {
	
	let bulletin: Bulletin
	
	@State private var isShowingLarge = false
	
	var date: String? {
		if let date = self.bulletin.createdAtTimestamp(includeDow: true) {
			return date
		}
		
		return nil
	}
	
	var body: some View {
		Button(action: {
			self.isShowingLarge.toggle()
		}) {
			VStack(alignment: .leading, spacing: Dimens.verticalPaddingXsm) {
				if let date = self.date {
					Text(date)
						.font(.footnote)
						.foregroundColor(.secondary)
						.padding(.leading, Dimens.horizontalPadding)
				}
				
				VStack(alignment: .leading, spacing: 0) {
					if let linkUrl = self.bulletin.linkURL {
						BulletinLinkPreview(url: linkUrl, maxHeight: 200)
							.frame(height: 200)
							.clipped()
					}
					else if let imageUrl = self.bulletin.imageURL {
						CachedAsyncImage(
							url: imageUrl,
							urlCache: .imageCache,
							transaction: Transaction(animation: .easeInOut)
						) { phase in
							switch phase {
							case .success(let image):
								image
									.resizable()
									.aspectRatio(contentMode: .fill)
									.frame(height: 200)
							case .failure:
								ZStack {
									Image(systemName: "photo.fill.on.rectangle.fill")
										.imageScale(.large)
								}
								.background(Color.background)
								.frame(height: 250)
							default:
								ZStack {
									ProgressView()
										.progressViewStyle(CircularProgressViewStyle(tint: Color.primary))
								}
								.background(Color.background)
								.frame(height: 250)
							}
						}
					}
					
					VStack {
						Text(self.bulletin.title)
							.font(.system(size: 17, weight: .medium))
							.foregroundColor(.primary)
							.lineLimit(1)
							.frame(maxWidth: .infinity, alignment: .leading)
						
						Text(self.bulletin.content)
							.font(.subheadline)
							.foregroundColor(.secondary)
							.lineLimit(2)
							.truncationMode(.tail)
							.multilineTextAlignment(.leading)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
					.padding(.horizontal, Dimens.horizontalPaddingMd)
					.padding(.vertical, Dimens.verticalPaddingMd)
				}
				.background(Color.background)
				.cornerRadius(8)
			}
		}
		.sheet(isPresented: self.$isShowingLarge) {
			BulletinSheetView(bulletin: self.bulletin)
				.presentationDetents([.medium, .large])
				.presentationDragIndicator(.visible)
		}
	}
}

fileprivate struct BulletinSheetView : View {
	
	@Environment(\.dismiss) private var dismiss
	
	let bulletin: Bulletin
	
	var body: some View {
		VStack(spacing: 0) {
			ZStack(alignment: .topTrailing) {
				if let linkUrl = self.bulletin.linkURL {
					BulletinLinkPreview(url: linkUrl, maxHeight: 250)
						.frame(height: 250)
						.clipped()
				}
				else if let imageUrl = self.bulletin.imageURL {
					CachedAsyncImage(
						url: imageUrl,
						urlCache: .imageCache,
						transaction: Transaction(animation: .easeInOut)
					) { phase in
						switch phase {
						case .success(let image):
							image
								.resizable()
								.aspectRatio(contentMode: .fill)
								.frame(height: 200)
						case .failure:
							ZStack {
								Image(systemName: "photo.fill.on.rectangle.fill")
									.imageScale(.large)
							}
							.background(Color.background)
							.frame(height: 250)
						default:
							ZStack {
								ProgressView()
									.progressViewStyle(CircularProgressViewStyle(tint: Color.primary))
							}
							.background(Color.background)
							.frame(height: 250)
						}
					}
				}
				else {
					Spacer(minLength: 30)
					.frame(maxWidth: .infinity, maxHeight: 30)
				}
				
				Button(action: {
					self.dismiss()
				}) {
					Avatar(type: .systemImage("xmark", .primary, .backgroundDark.opacity(0.5)),
						   size: .custom(40),
						   state: .normal)
					.padding(.trailing, Dimens.horizontalPadding)
					.padding(.top, Dimens.verticalPadding)
				}
			}
			
			ScrollView {
				VStack(spacing: Dimens.verticalPadding) {
					Text(self.bulletin.title)
						.font(.largeTitle)
						.foregroundStyle(.primary)
						.frame(maxWidth: .infinity, alignment: .leading)
					
					Text(self.bulletin.content)
						.font(.body)
						.foregroundColor(.secondary)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
				.padding(.horizontal, Dimens.horizontalPadding)
				.padding(.vertical, Dimens.verticalPadding)
			}
		}
	}
}
