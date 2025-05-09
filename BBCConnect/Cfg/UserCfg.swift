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
	
	public static func avatar() -> String? {
		if let avatar = CfgManager.shared.getValue(cfgType: .avatar) as? String {
			return avatar
		}
		
		return nil
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
	
	public static func role() -> String? {
		return CfgManager.shared.getValue(cfgType: .role) as? String
	}
	
	public static func isAdmin() -> Bool {
		if let role = self.role() {
			return role == "admin"
		}
		
		return false
	}
	
	public static func initials() -> String {
		if let firstName = self.firstName(), let lastName = self.lastName() {
			return "\(firstName.first!)\(lastName.first!)"
		}
		
		return "BBC"
	}
	
	public static func sessionToken() -> String? {
		if let token = CfgManager.shared.getValue(cfgType: .sessionToken) as? String {
			return token
		}
		
		return nil
	}
	
	public static func userId() -> Int? {
		return CfgManager.shared.getValue(cfgType: .userId) as? Int
	}
	
	public static func setAvatar(avatar: String?) {
		if let avatar = avatar {
			CfgManager.shared.setValue(cfgType: .avatar, value: avatar)
		}
		else {
			CfgManager.shared.removeValue(cfgType: .avatar)
		}
	}
	
	public static func setEmail(email: String) {
		CfgManager.shared.setValue(cfgType: .email, value: email)
	}
	
	public static func setFirstName(firstName: String) {
		CfgManager.shared.setValue(cfgType: .firstName, value: firstName)
	}
	
	public static func setLastName(lastName: String) {
		CfgManager.shared.setValue(cfgType: .lastName, value: lastName)
	}
	
	public static func setRole(role: String) {
		CfgManager.shared.setValue(cfgType: .role, value: role)
	}
	
	public static func setUserId(userId: Int) {
		CfgManager.shared.setValue(cfgType: .userId, value: userId)
	}
	
	public static func setSessionToken(sessionToken: String) {
		CfgManager.shared.setValue(cfgType: .sessionToken, value: sessionToken)
	}
	
	public static func logIn(result: UserAuthentication) {
		Self.updateUser(user: result.user)
		Self.setSessionToken(sessionToken: result.token)
	}
	
	public static func updateUser(user: User) {
		Self.setUserId(userId: user.id)
		Self.setEmail(email: user.email)
		Self.setFirstName(firstName: user.first_name)
		Self.setLastName(lastName: user.last_name)
		Self.setRole(role: user.role)
		Self.setAvatar(avatar: user.avatar)
	}
	
	public static func logOut() {
		CfgManager.shared.clearSession()
	}
}
