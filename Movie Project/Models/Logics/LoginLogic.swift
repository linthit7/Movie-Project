//
//  LoginLogic.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/30/23.
//

import Foundation

enum LoginError: Error {
    case wrongCredentials
}

struct LoginLogic {
    
    static func checkCredentials(username un: String, password pw: String) throws {
        if un == acc.username, pw == acc.password {
            Request.validateWithUser(username: un, password: pw, requestToken: AuthLogic.getAuthToken()!)
        } else {
            throw LoginError.wrongCredentials
        }
    }
    
}
