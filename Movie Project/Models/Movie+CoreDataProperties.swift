//
//  Movie+CoreDataProperties.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/10/23.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var movieTitle: String?
    @NSManaged public var overView: String?
    @NSManaged public var backDropImage: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var rating: NSNumber?
    @NSManaged public var movieID: NSNumber?
    @NSManaged public var favoriteState: NSNumber?

}

extension Movie : Identifiable {

}
