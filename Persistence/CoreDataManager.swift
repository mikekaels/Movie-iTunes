//
//  CoreDataManager.swift
//  Persistence
//
//  Created by Santo Michael on 11/02/24.
//

import Foundation
import CoreData

/// A protocol defining requirements for a Core Data manager.
public protocol CoreDataManagerProtocol {
	/// Saves changes made to the managed object context.
	func saveContext()
	
	/// Fetches objects of a specific type from the managed object context.
	///
	/// - Parameters:
	///   - objectType: The type of objects to fetch.
	///   - predicate: An optional predicate to filter the results.
	/// - Returns: An array of fetched objects.
	func fetch<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate?) -> [T]
	
	/// Creates a new instance of a specific type of managed object.
	///
	/// - Parameter objectType: The type of object to create.
	/// - Returns: The newly created object, or nil if creation fails.
	func create<T: NSManagedObject>(_ objectType: T.Type) -> T?
	
	/// Deletes a managed object from the managed object context.
	///
	/// - Parameter object: The object to delete.
	func delete(_ object: NSManagedObject)
}

// Core Data manager
public class CoreDataManager: CoreDataManagerProtocol {
	let containerName: String
	
	public init(containerName: String) {
		self.containerName = containerName
	}
	
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: containerName)
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	var viewContext: NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	
	public func saveContext() {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
	public func fetch<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate? = nil) -> [T] {
		let entityName = String(describing: objectType)
		let fetchRequest = NSFetchRequest<T>(entityName: entityName)
		fetchRequest.predicate = predicate
		
		do {
			let fetchedObjects = try viewContext.fetch(fetchRequest)
			return fetchedObjects
		} catch {
			print(error)
			return []
		}
	}
	
	public func create<T: NSManagedObject>(_ objectType: T.Type) -> T? {
		guard let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: objectType), in: viewContext) else {
			return nil
		}
		
		let object = T(entity: entityDescription, insertInto: viewContext)
		return object
	}
	
	public func delete(_ object: NSManagedObject) {
		viewContext.delete(object)
		saveContext()
	}
}
