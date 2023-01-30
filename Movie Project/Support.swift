//
//  Support.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/6/23.
//

import Foundation

struct Support {
    static let baseURL: String = "https://api.themoviedb.org/3"
    static let apiKey: String = "bc1f66a36bd7929eb408d7facc60ec74"
    static let posterImageURL: String = "https://image.tmdb.org/t/p/w500"
    static let backDropImageURL: String = "https://image.tmdb.org/t/p/w500"
    static let popularMovieEndPoint: String = "/movie/popular"
    static let upcomingMovieEndPoint: String = "/movie/upcoming"
    static let searchMovieEndPoint: String = "/search/movie"
    static let newAccessTokenEndPoint: String = "/authentication/token/new"
    static let validateTokenEndPoint: String = "/authentication/token/validate_with_login"
    static let newSessionEndPoint: String = "/authentication/session/new"
    static let accountEndPoint: String = "/account"
    static let deleteSessionEndPoint: String = "/authentication/session"
}

struct getVC {
    static let popularVC: String = "PopularViewController"
    static let upcomingVC: String = "UpcomingViewController"
    static let searchResultsVC: String = "SearchResultsViewController"
    static let favoriteVC: String = "FavoriteViewController"
    static let similarVC: String = "SimilarViewController"
}

struct acc {
    static let username: String = "linthit"
    static let password: String = "2023Upcoming"
}
