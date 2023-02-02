//
//  NotiControl.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 2/2/23.
//

import Foundation

struct SessionNotfication {
    static func post(aMessage: String) {
        let aMessage: [String: String] = ["accountMessage": aMessage]
        NotificationCenter.default.post(name: Notification.Name(noti.sessionState), object: nil,userInfo: aMessage)
    }
}

struct LoginNotification {
    static func post() {
        NotificationCenter.default.post(name: NSNotification.Name(noti.loginState), object: nil)
    }
}

struct AuthNotification {
    static func post(aMessage: String) {
        let aMessage: [String: String] = ["errorMessage": aMessage]
        NotificationCenter.default.post(name: NSNotification.Name(noti.authState), object: nil, userInfo: aMessage)
        print("Success post")
    }
}

struct SettingsNotification {
    static func post() {
        NotificationCenter.default.post(name: NSNotification.Name(noti.logout), object: nil)
    }
}

struct FavoriteNotification {
    static func post(aMessage: String) {
        let aMessage: [String: String] = ["favoriteMessage": aMessage]
        NotificationCenter.default.post(name: Notification.Name(noti.favoriteState), object: nil, userInfo: aMessage)
    }
}
