//
//  CfgManager.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation

// MARK: - Notification names
extension Notification.Name {
	public static let CfgChanged = Notification.Name("CfgChanged")
}

// MARK: - Notification payloads
public struct CfgPayload {
	public var cfgType: CfgType
}


// MARK: - Cfg types
public enum CfgType: Int, CaseIterable {
	case email        = 0
	case firstName    = 1
	case lastName     = 2
	case sessionToken = 3
	case userId       = 4
	case avatar       = 5
	
	func key() -> String {
		return "\(self.rawValue)"
	}
	
	public func updateTimeKey() -> String {
		return "\(self.key())-updateTime"
	}
}

// MARK: - CfgManager
public class CfgManager {
	
	public static let shared = CfgManager()
	
	private init() {
		self.initDefaults()
	}
	
	public func clearSession() {
		print("[AUTH] clear session called")

		// Remove all cfg values but wait to notify until after all are cleared and new defaults are created
		CfgType.allCases.forEach {
			self.removeValue(cfgType: $0, notify: false)
		}
		
		// Re-initialize our defaults so we can apply default values
		self.initDefaults(fromLogout: true)
		
		// Now we can notify
		CfgType.allCases.forEach {
			self.postNotification(cfgType: $0)
		}
	}
	
	// MARK: - Cfg functions
	
	public func hasValue(cfgType: CfgType) -> Bool {
		let key = cfgType.key()
		return UserDefaults.standard.object(forKey: key) != nil
	}
	
	public func getValue(cfgType: CfgType) -> Any? {
		let key = cfgType.key()
		
		switch (cfgType) {
		case .email,
				.firstName,
				.lastName,
				.sessionToken,
				.avatar:
			return UserDefaults.standard.string(forKey: key)
		case .userId:
			return UserDefaults.standard.integer(forKey: key)
		}
	}
	
	public func removeValue(cfgType: CfgType, notify: Bool = true) {
		UserDefaults.standard.removeObject(forKey: cfgType.key())
		UserDefaults.standard.removeObject(forKey: cfgType.updateTimeKey())
		
		if notify {
			self.postNotification(cfgType: cfgType)
		}
	}
	
	public func setValue(cfgType: CfgType, value: Any, updateTimeMs: Int? = nil, isDefault: Bool = false) {
		var changed: Bool = true
		
		let key = cfgType.key()
		let oldValue = self.getValue(cfgType: cfgType)
		
		UserDefaults.standard.set(value, forKey: key)
		
		// We only want to update the updateTimeMs and post a notification if our value has changed
		let newValue: Any? = value
		changed = String(describing: oldValue) != String(describing: newValue)
		
		// We only want to update the updateTimeMs and post a notification if our value has changed
		if changed && !isDefault {
			if let updateTimeMs = updateTimeMs {
				UserDefaults.standard.set(updateTimeMs, forKey: cfgType.updateTimeKey())
			}
			else {
				UserDefaults.standard.set(Date().timeIntervalSince1970Ms, forKey: cfgType.updateTimeKey())
			}
		
			self.postNotification(cfgType: cfgType)
		}
	}
	
	// MARK: - Fileprivate functions
	
	fileprivate func initDefaults(fromLogout: Bool = false) {
		for cfgType in CfgType.allCases {
			let key = cfgType.key()
			
			if UserDefaults.standard.object(forKey: key) != nil {
				// don't overwrite what's there
				continue
			}
			
			// TODO init any defaults here
		}
	}
	
	fileprivate func postNotification(cfgType: CfgType) {
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: Notification.Name.CfgChanged, object: CfgPayload(cfgType: cfgType))
		}
	}
}
