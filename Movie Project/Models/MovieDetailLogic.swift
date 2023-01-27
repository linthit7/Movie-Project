//
//  CRUD.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/13/23.
//

import Foundation
import CoreData
import UIKit

struct MovieDetailLogic {
    
    static func delete(id: Int) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "movieID = %@", "\(id)")
        
        do {
            guard let result = try managedContext.fetch(fetchRequest) as? [Movie] else {return}
            guard let movie = result.first else {return}
            managedContext.delete(movie)
            do {
                try managedContext.save()
            }
        } catch let error {
            print(error)
        }
    }
    
    static func tempData(viewController: String, movieObject: Movie, completion: @escaping (Movie) -> Void) {
        if viewController == "WatchlistViewController" {
            let tempObject = movieObject
            completion(tempObject)
        }
    }
}
