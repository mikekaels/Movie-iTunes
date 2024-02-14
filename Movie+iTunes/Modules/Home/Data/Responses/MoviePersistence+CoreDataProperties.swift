//
//  MoviePersistence+CoreDataProperties.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//
//

import Foundation
import CoreData


extension MoviePersistence {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoviePersistence> {
        return NSFetchRequest<MoviePersistence>(entityName: "MoviePersistence")
    }

	@NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var desc: String?
    @NSManaged public var year: String?
    @NSManaged public var trailer: String?
	
    @NSManaged public var posterPathTiny: String?
    @NSManaged public var posterPathLarge: String?
	
    @NSManaged public var imageTiny: Data?
	@NSManaged public var imageLarge: Data?
	
    @NSManaged public var favorited: Bool
    @NSManaged public var genre: String?
    @NSManaged public var price: String?

}

extension MoviePersistence : Identifiable {

}
