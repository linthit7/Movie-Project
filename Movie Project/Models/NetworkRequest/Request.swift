//
//  Request.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/13/23.
//

import Foundation
import SwiftyJSON
import Alamofire

class Request {
    
    var isPaginating: Bool = false
    
    func movieRequest(url: String, queryName: String = "", pagination: Bool = false,pageCount count: Int = 1, pageTotal total: Int = 0, id: Int = 0, completion: @escaping ([MovieResult], Int, Int) -> Void)
    {
        guard !isPaginating else {
            return
        }
        var pageCount = count
        var pageTotal: Int = total
        let movieID: Int = id
        
        var certainURL: String {
            switch url {
            case "PopularVC": return
                "\(Support.baseURL)\(Support.popularMovieEndPoint)?api_key=\(Support.apiKey)&page=\(pageCount)"
            case "UpcomingVC": return
                "\(Support.baseURL)\(Support.upcomingMovieEndPoint)?api_key=\(Support.apiKey)&page=\(pageCount)"
            case "SearchResultsVC": return "\(Support.baseURL)\(Support.searchMovieEndPoint)?api_key=\(Support.apiKey)&page=\(pageCount)&query=\(queryName)"
            case "SimilarVC": return
                "\(Support.baseURL)/movie/\(movieID)/similar?api_key=\(Support.apiKey)"
            default: return ("default case")
            }
        }
        
        var movie: OnlineMovie!
        var movieList: [MovieResult] = []
        
        if pageCount < pageTotal {
            print(pageCount)
            pageCount += 1
        }
        if pagination {
            isPaginating = true
        }
        let requestQueue = DispatchQueue(label: "Request", qos: .userInitiated)
        requestQueue.async {
            Alamofire.request(certainURL, method: .get).responseJSON { response in
                switch response.result {
                case .success:
                    let jSON: JSON = JSON(response.result.value!)
                    movie = OnlineMovie.loadJSON(json: jSON)
                    movieList.append(contentsOf: movie.results)
                    if pageTotal == 0 {
                        pageTotal = movie.total_pages
                    }
                    completion(movieList, pageCount, pageTotal)
                case .failure(let error):
                    print("Error", error)
                }
                if pagination {
                    self.isPaginating = false
                }
            }
        }
    }
}
