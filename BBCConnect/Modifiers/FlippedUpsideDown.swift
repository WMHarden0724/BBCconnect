//
//  FlippedUpsideDown.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/21/25.
//

import SwiftUI

struct FlippedUpsideDown: ViewModifier {
   func body(content: Content) -> some View {
	content
	  .rotationEffect(Angle.radians(.pi))
	  .scaleEffect(x: -1, y: 1, anchor: .center)
   }
}

extension View{
   func flippedUpsideDown() -> some View{
	 self.modifier(FlippedUpsideDown())
   }
}
