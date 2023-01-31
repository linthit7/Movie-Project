//
//  AccountDetail.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/30/23.
//

import Foundation
import SwiftyJSON

struct Account {
    var avatar: Avatar!
    var id: String!
    var iso_639_1: String!
    var iso_3166_1: String!
    var name: String!
    var include_adult: Bool!
    var username: String!
    
    static func loadAccount(json: JSON) -> Account {
        var account = Account()
        account.avatar = Avatar.loadAvatar(json: JSON(rawValue: json["avatar"].dictionaryValue)!)
        account.id = json["id"].stringValue
        account.iso_639_1 = json["iso_639_1"].stringValue
        account.iso_3166_1 = json["iso_3166_1"].stringValue
        account.name = json["name"].stringValue
        account.include_adult = json["include_adult"].boolValue
        account.username = json["username"].stringValue
        return account
    }
}

struct Avatar {
    var gravatar: Dictionary<String, Any>!
    var tmdb: Dictionary<String, Any>!
    
    static func loadAvatar(json: JSON) -> Avatar {
        var avatar = Avatar()
        avatar.gravatar = json["gravatar"].dictionaryValue
        avatar.tmdb = json["tmdb"].dictionaryValue
        return avatar
    }
}

struct FavoriteResponse {
    var success: Bool!
    var status_code: Int!
    var status_message: String!
    
    static func load(json: JSON) -> FavoriteResponse {
        var favoriteResponse = FavoriteResponse()
        favoriteResponse.success = json["success"].boolValue
        favoriteResponse.status_code = json["status_code"].intValue
        favoriteResponse.status_message = json["status_message"].stringValue
        return favoriteResponse
    }
}
