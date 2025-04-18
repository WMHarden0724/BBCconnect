//
//  CfgChanged.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

public extension View {
	func onCfgChanged(onChanged: @escaping (_ cfgType: CfgType, _ value: Any?) -> Void) -> some View {
		onReceive(NotificationCenter.default.publisher(for: Notification.Name.CfgChanged)) { payload in
			if let payload = payload.object as? CfgPayload {
				onChanged(payload.cfgType, CfgManager.shared.getValue(cfgType: payload.cfgType))
			}
		}
	}
}
