//
//  Movie+CoreDataProperties.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/12/23.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var backDropImage: String?
    @NSManaged public var favoriteState: NSNumber?
    @NSManaged public var genreName: String?
    @NSManaged public var movieID: Int64
    @NSManaged public var movieTitle: String?
    @NSManaged public var overView: String?
    @NSManaged public var posterImage: String?
    @NSManaged public var rating: NSNumber?
    @NSManaged public var releaseDate: String?

}

extension Movie : Identifiable {

}
