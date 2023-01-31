//
//  CRUD.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/13/23.
//

import CoreData
import SwiftyJSON

struct MovieLogic {
    
    static func fetchAnObject(getMovie movie: MovieResult) -> Bool? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return nil}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        fetchRequest.predicate = NSPredicate(format: "movieID = %@", "\(movie.id!)")
        do {
            let object = try managedContext.fetch(fetchRequest)
            if object.isEmpty {return true} else {return false}
        } catch let error {
            print(error)
        }
        return nil
    }
    
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
        if viewController == getVC.favoriteVC {
            let tempObject = movieObject
            completion(tempObject)
        }
    }
    
    static func genreIDArrayConversion(insert intArray: [JSON]) -> [String]{
        var genreNameArray: [String] = []
        for g in 0..<intArray.count {
            let genreInt: Int = intArray[g].rawValue as! Int
            genreNameArray.append(Genre(genreID: genreInt).genreName)
        }
        return genreNameArray
    }
    
    static func movieFetch() -> [Movie]?{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return nil}
        let managedContext = appDelegate.persistentContainer.viewContext
        let  fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        
        do {
            guard let result = try managedContext.fetch(fetchRequest) as? [Movie] else {return nil}
            return result
        } catch let error as NSError {
            debugPrint(error)
        }
        return nil
    }
}
