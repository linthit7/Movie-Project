//
//  PopularMovie.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/11/23.
//

import Foundation
import SwiftyJSON

struct OnlineMovie {
    var page: Int!
    var results: [MovieResult]!
    var total_pages: Int!
    var total_results: Int!
    
    static func loadJSON(json: JSON) -> OnlineMovie{
        var movie = OnlineMovie()
        movie.page = json["page"].intValue
        movie.results = MovieResult.loadJSONArray(jsonArray: json["results"].arrayValue)
        movie.total_pages = json["total_pages"].intValue
        movie.total_results = json["total_results"].intValue
        return movie
    }
}

struct MovieResult {
    var adult: Bool!
    var backdrop_path: String!
    var genre_ids: [JSON]!
    var id: Int!
    var overview: String!
    var poster_path: String!
    var release_date: String!
    var title: String!
    var vote_average: Float!
    
    static func loadJSON(json: JSON) -> MovieResult{
        var results = MovieResult()
        results.adult = json["adult"].boolValue
        results.backdrop_path = json["backdrop_path"].stringValue
        results.genre_ids = json["genre_ids"].arrayValue
        results.id = json["id"].intValue
        results.overview = json["overview"].stringValue
        results.poster_path = json["poster_path"].stringValue
        results.release_date = json["release_date"].stringValue
        results.title = json["title"].stringValue
        results.vote_average = json["vote_average"].floatValue
        return results
    }
    
    static func loadJSONArray(jsonArray: [JSON]) -> [MovieResult]{
        var resultList: [MovieResult] = []
        for json in jsonArray {
            let result = MovieResult.loadJSON(json: json)
            resultList.append(result)
        }
        return resultList
    }
}
