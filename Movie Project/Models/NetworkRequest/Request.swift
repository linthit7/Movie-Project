//
//  Request.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/13/23.
//

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
            case getVC.popularVC: return
                "\(Support.baseURL)\(Support.popularMovieEndPoint)?api_key=\(Support.apiKey)&page=\(pageCount)"
            case getVC.upcomingVC: return
                "\(Support.baseURL)\(Support.upcomingMovieEndPoint)?api_key=\(Support.apiKey)&page=\(pageCount)"
            case getVC.searchResultsVC: return "\(Support.baseURL)\(Support.searchMovieEndPoint)?api_key=\(Support.apiKey)&page=\(pageCount)&query=\(queryName)"
            case getVC.similarVC: return
                "\(Support.baseURL)/movie/\(movieID)/similar?api_key=\(Support.apiKey)"
            default: return ("default case")
            }
        }
        
        var movie: OnlineMovie!
        var movieList: [MovieResult] = []
        
        if pageCount < pageTotal {
            pageCount += 1
        }
        if pagination {
            isPaginating = true
        }
        let requestQueue = DispatchQueue(label: "Request", qos: .userInitiated)
        requestQueue.async {
            Alamofire.request(certainURL, method: .get).responseJSON { [weak self] response in
                switch response.result {
                case .success:
                    let jSON: JSON = JSON(response.result.value!)
                    movie = OnlineMovie.loadJSON(json: jSON)
                    movieList.append(contentsOf: movie.results)
                    if pageTotal == 0 {
                        pageTotal = movie.total_pages
                    }
                    print("Request Called")

                    completion(movieList, pageCount, pageTotal)
                case .failure(let error):
                    print("Error", error)
                }
                if pagination {
                    self?.isPaginating = false
                }
            }
        }
    }
    
    static func generateNewRequestToken() {
        let requestTokenURL = "\(Support.baseURL)\(Support.newAccessTokenEndPoint)?api_key=\(Support.apiKey)"
        let requestQueue = DispatchQueue(label: "Request", qos: .userInitiated)
        requestQueue.async {
            Alamofire.request(requestTokenURL, method: .get).responseJSON { response in
                switch response.result {
                case .success:
                    let jSON: JSON = JSON(response.result.value!)
                    let newToken = AuthToken.createNewToken(json: jSON)
                    AuthLogic.insertToken(newAuthToken: newToken)
                    
                case .failure(let error): print(error)
                }
            }
        }
    }
    
    static func validateWithUser(username un: String, password pw: String, requestToken token: String) {
        let validateTokenURL = "\(Support.baseURL)\(Support.validateTokenEndPoint)?api_key=\(Support.apiKey)"
        let params: Parameters = [
            "username": un,
            "password": pw,
            "request_token": token
        ]
        let requestQueue = DispatchQueue(label: "Request", qos: .userInitiated)
        requestQueue.async {
            Alamofire.request(validateTokenURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).response { response in
                switch response.data {
                case .some(let data):
                    let jSON: JSON = JSON(data)
                    let validatedToken = AuthToken.createNewToken(json: jSON)
                    if validatedToken.success {
                        print("Validation Success")
                        createSession(validatedToken: validatedToken)
                        AuthLogic.removeAuthToken()
                        self.generateNewRequestToken()
                    } else {
                        print("Validation failed")
                        AuthLogic.removeAuthToken()
                        self.generateNewRequestToken()
                    }
                case .none:
                    print("No resposnse data for validation")
                }
            }
        }
    }
    
    static func createSession(validatedToken: AuthToken) {
        let newSessionURL = "\(Support.baseURL)\(Support.newSessionEndPoint)?api_key=\(Support.apiKey)"
        let params: Parameters = [
            "request_token": validatedToken.request_token!
        ]
        let requestQueue = DispatchQueue(label: "requestQueue", qos: .userInitiated)
        requestQueue.async {
            Alamofire.request(newSessionURL, method: .post, parameters: params, headers: nil).response { response in
                switch response.data {
                case .some(let data) :
                    let jSON: JSON = JSON(data)
                    let session = AccountSession.createSessionID(json: jSON)
                    if session.success {
                        print("Session created")
                        AuthLogic.insertSession(newSession: session)
//                        self.getAccountDetail(sessionID: session.session_id)
                    } else {
                        print("Failed to create session")
                    }
                case .none :
                    print("No response data for session creation")
                }
            }
        }
    }
    
    static func getAccountDetail(sessionID: String, completion: @escaping (Account) -> Void) {
        let accountDetailURL = "\(Support.baseURL)\(Support.accountEndPoint)?api_key=\(Support.apiKey)&session_id=\(sessionID)"
        let requestQueue = DispatchQueue(label: "requestQueue", qos: .userInitiated)
        requestQueue.async {
            Alamofire.request(accountDetailURL, method: .get).response { response in
                switch response.data {
                case .some(let data) :
                    let jSON = JSON(data)
                    completion(Account.loadAccount(json: jSON))
                case .none :
                    print("No response data for account detail")
                }
            }
        }
    }
    
    static func deleteSession(sessionID: String) {
        let deleteURL = "\(Support.baseURL)\(Support.deleteSessionEndPoint)?api_key=\(Support.apiKey)&session_id=\(sessionID)"
        let requestQueue = DispatchQueue(label: "requestQueue", qos: .userInitiated)
        requestQueue.async {
            Alamofire.request(deleteURL, method: .delete).response { response in
                switch response.data {
                case .some(let data) :
                    let jSON = JSON(data)
                    if jSON["success"].boolValue {
                        print("Session delete from server")
                        AuthLogic.removeSession()
                    } else {
                        print("There is no session to delete")
                    }
                case .none :
                    print("No response data for session deletion")
                }
            }
        }
    }
    
    static func updateFavorite(mediaType: String = "movie", mediaId: Int, favorite: Bool, sessionId: String, completion: @escaping (FavoriteResponse) -> Void) {
        let favoriteURL  = "\(Support.baseURL)\(Support.updateFavoriteEndPoint)?api_key=\(Support.apiKey)&session_id=\(sessionId)"
        let params: Parameters = [
            "media_type": mediaType,
            "media_id": mediaId,
            "favorite": favorite
        ]
        let requestQueue = DispatchQueue(label: "requestQueue", qos: .userInitiated)
        requestQueue.async {
            Alamofire.request(favoriteURL, method: .post, parameters: params, headers: nil).response { response in
                switch response.data {
                case .some(let data):
                    print(params)
                    print(favoriteURL)
                    let jSON: JSON = JSON(data)
                    let favResponse = FavoriteResponse.load(json: jSON)
                    print(jSON)
                    if favResponse.success {
                        print("update themovie favorite")
                        completion(favResponse)
                    }
                case .none:
                    print("No response data for favorite")
                }
            }
        }
    }
    
    
}
