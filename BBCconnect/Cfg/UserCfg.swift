//
//  UserCfg.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

public struct UserCfg {
	
	public static func isLoggedIn() -> Bool {
		if let sessionToken = CfgManager.shared.getValue(cfgType: .sessionToken) as? String {
			return !sessionToken.isEmpty
		}
		return false
	}
	
	public static func email() -> String? {
		return CfgManager.shared.getValue(cfgType: .email) as? String
	}
	
	public static func firstName() -> String? {
		return CfgManager.shared.getValue(cfgType: .firstName) as? String
	}
	
	public static func lastName() -> String? {
		return CfgManager.shared.getValue(cfgType: .lastName) as? String
	}
	
	public static func userId() -> Int? {
		return CfgManager.shared.getValue(cfgType: .userId) as? Int
	}
	
	public static func logIn(result: UserAuthentication) {
		CfgManager.shared.setValue(cfgType: .email, value: result.user.email)
		CfgManager.shared.setValue(cfgType: .firstName, value: result.user.first_name)
		CfgManager.shared.setValue(cfgType: .lastName, value: result.user.last_name)
		CfgManager.shared.setValue(cfgType: .sessionToken, value: result.token)
	}
	
	public static func logOut() {
		CfgManager.shared.clearSession()
	}
}
