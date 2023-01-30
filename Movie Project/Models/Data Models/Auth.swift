//
//  Authentication.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/29/23.
//

import Foundation
import SwiftyJSON

struct AuthToken: Codable {
    
    var success: Bool!
    var expires_at: String!
    var request_token: String!
    
    static func createNewToken(json: JSON) -> AuthToken {
        var authToken = AuthToken()
        authToken.success = json["success"].boolValue
        authToken.expires_at = json["expires_at"].stringValue
        authToken.request_token = json["request_token"].stringValue
        return authToken
    }
}

struct AccountSession: Codable {
    
    var success: Bool!
    var session_id: String!
    
    static func createSessionID(json: JSON) -> AccountSession {
        var accountSession = AccountSession()
        accountSession.success = json["success"].boolValue
        accountSession.session_id = json["session_id"].stringValue
        return accountSession
    }
}
