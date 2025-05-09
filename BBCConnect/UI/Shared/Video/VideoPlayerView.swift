//
//  File.swift
//  
//
//  Created by Айтолкун Анарбекова on 29.11.2023.
//

import SwiftUI
import AVKit

@available(iOS 14.0, *)
public struct VideoPlayerView: View {
    
    @State private var isPlaying = false
    @State private var showControls = true
    @State private var timer: Timer?
    
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    
    @State var player: AVPlayer
	@Binding var isPlayerFullScreen: Bool
	let isLive: Bool
	let streamKey: String?
    let timecodes: [Timecode]
	let enabled: Bool
    
    public var body: some View {
        
        let controlButtons = PlayerControlButtons(
            isPlaying: $isPlaying,
            timer: $timer,
            showPlayerControlButtons: $showControls,
            isPlayerFullScreen: $isPlayerFullScreen,
            avPlayer: $player,
            timecodes: timecodes,
			streamKey: streamKey
        )
        
        let player = VideoPlayer(player: $player)
        VStack {
            
			ZStack(alignment: .topLeading) {
				ZStack {
					player
					if !enabled {
						if let streamKey = streamKey {
							VStack {
								Spacer()
								Text("Stream Key: \(streamKey)")
									.font(.system(size: 9))
									.foregroundColor(.secondary)
									.frame(maxWidth: .infinity, alignment: .trailing)
									.multilineTextAlignment(.trailing)
									.padding(.trailing, 5)
									.padding(.bottom, 5)
									.backgroundGradientIgnoreSafeArea(colorStart: .clear, colorEnd: .black)
							}
						}
					}
					else if showControls {
						controlButtons
					}
				}
				
				if isLive {
					LiveIndicator(isFullScreen: false)
				}
			}
            .frame(height: frameHeight(for: orientation))
            .onTapGesture {
				if enabled {
					withAnimation {
						showControls.toggle()
					}
					if isPlaying {
						startTimer()
					}
				}
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                    orientation = UIDevice.current.orientation
                }
            }
            .statusBar(hidden: true)
            .preferredColorScheme(.dark)
			.onChange(of: isPlayerFullScreen, initial: false) { _, _ in
				if !isPlayerFullScreen {
					self.player.pause()
					timer?.invalidate()
				}
			}
            .fullScreenCover(isPresented: $isPlayerFullScreen) {
				ZStack(alignment: .topLeading) {
					ZStack {
						player
						if showControls {
							controlButtons
						}
					}
					
					if isLive {
						LiveIndicator(isFullScreen: true)
					}
				}
                .onTapGesture {
                    withAnimation {
                        showControls.toggle()
                    }
                    if isPlaying {
                        startTimer()
                    }
                }
                .frame(height: frameHeightFullScreen(for: orientation))
            }
        }
    }
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
            withAnimation {
                showControls = false
            }
        }
    }
    
    private func frameHeightFullScreen(for orientation: UIDeviceOrientation) -> CGFloat {
//        let screenHeight = UIScreen.main.bounds.height
//        if orientation.isPortrait {
//            return UIDevice.current.userInterfaceIdiom == .pad ? screenHeight * 0.4 : screenHeight * 0.33
//        }
//        else {
            return UIScreen.main.bounds.height - 20
//        }
    }
    
    private func frameHeight(for orientation: UIDeviceOrientation) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        if orientation.isLandscape {
            return UIDevice.current.userInterfaceIdiom == .pad ? screenHeight * 0.8 : screenHeight * 0.66
        }
        else {
            return UIDevice.current.userInterfaceIdiom == .pad ? screenHeight * 0.4 : screenHeight * 0.33
        }
    }
}
