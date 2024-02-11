//
//  CoreDataManager.swift
//  Persistence
//
//  Created by Santo Michael on 11/02/24.
//

import Foundation
import CoreData

public protocol CoreDataManagerProtocol {
	func saveContext()
	func fetch<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate?) -> [T]
	func create<T: NSManagedObject>(_ objectType: T.Type) -> T?
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
