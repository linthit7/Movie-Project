//
//  AuthenticationLogic.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/29/23.
//

import Foundation

struct AuthLogic {
    
    static func checkToken() {
        if let authToken = AppDelegate.defaults.data(forKey: "AuthToken") {
            do {
                let data = try JSONDecoder().decode(AuthToken.self, from: authToken)
                print("Existing Token")
                print(data)
                let removedUTC = data.expires_at.replacingOccurrences(of: "UTC", with: "")
                print(removedUTC)
                compareDate(expireDate: getExpireDate(tokenDate: removedUTC))
            } catch {
                print(error)
            }
        } else {
            Request.generateNewRequestToken()
        }
    }
    
    static func checkSession() -> Bool {
        if let session = AppDelegate.defaults.data(forKey: "AccountSession") {
            do {
                let data = try JSONDecoder().decode(AccountSession.self, from: session)
                print("Existing Session")
                print(data)
                return true
            } catch let error {
                print(error)
            }
        }
        return false
    }
    
    static func getExpireDate(tokenDate: String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        print(tokenDate, "from getExpireDate")
        let expireDate = dateFormatter.date(from: tokenDate)!
        return expireDate
    }
    
    static func compareDate(expireDate: Date) {
        let currentTime = Date()
        print(currentTime, "Current Time")
        if currentTime.addingTimeInterval(900) > expireDate {
            self.removeAuthToken()
            Request.generateNewRequestToken()
        } else {
            print(expireDate, "Expire Time")
        }
    }
    
    static func insertToken(newAuthToken: AuthToken) {
        do {
            print(newAuthToken)
            let data = try JSONEncoder().encode(newAuthToken)
            AppDelegate.defaults.set(data, forKey: "AuthToken")
        } catch let error {
            print(error)
        }
    }
    
    static func removeAuthToken() {
        AppDelegate.defaults.removeObject(forKey: "AuthToken")
    }
    
    static func getAuthToken() -> String? {
        if let authToken = AppDelegate.defaults.data(forKey: "AuthToken") {
            do {
                let data = try JSONDecoder().decode(AuthToken.self, from: authToken)
                return data.request_token
            } catch {
                print(error)
            }
        }
        return nil
    }
    
    static func insertSession(newSession: AccountSession) {
        do {
            print(newSession)
            let data = try JSONEncoder().encode(newSession)
            AppDelegate.defaults.set(data, forKey: "AccountSession")
            print("Session inserted to defaults")
            AppDelegate.sessionState = true
            NotificationCenter.default.post(name: Notification.Name(noti.sessionState), object: nil)
        } catch let error {
            print(error)
        }
    }
    
    static func removeSession() {
        AppDelegate.defaults.removeObject(forKey: "AccountSession")
        print("Session delete from defaults")
        AppDelegate.sessionState = false
        NotificationCenter.default.post(name: Notification.Name(noti.sessionState), object: nil)
    }
    
    static func getSession() -> String? {
        if let session = AppDelegate.defaults.data(forKey: "AccountSession") {
            do {
                let data = try JSONDecoder().decode(AccountSession.self, from: session)
                return data.session_id
            } catch {
                print(error)
            }
        }
        return nil
    }
    
}
