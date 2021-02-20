// 
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

extension NSPersistentContainer {
	public typealias StoreLoadFailure = (store: NSPersistentStoreDescription, error: Error)
	public typealias StoreLoadResult = (store: NSPersistentStoreDescription, error: Error?)
	public typealias LoadedStoresCompletion = ([StoreLoadResult]) -> Void
	
	public enum LoadError: Error {
		case modelNotFound(URL?)
		case loadPersistentStoresFailed([StoreLoadFailure])
	}
	
	public static func loadContainer(
		name: String, modelURL: URL, storeURL: URL,
		loadedStores: LoadedStoresCompletion? = nil
	) throws -> NSPersistentContainer {
		let container = createPersistentContainer(
			with: name,
			   at: storeURL,
			   using: try loadModel(from: modelURL))
		
		try loadPersistentStore(for: container, completion: loadedStores)

		return container
	}
	
	private static func loadModel(from modelURL: URL) throws -> NSManagedObjectModel {
		return try NSManagedObjectModel(contentsOf: modelURL)
			.unwrap(throw: LoadError.modelNotFound(modelURL))
	}
	
	private static func createPersistentContainer(
		with name: String,
		at storeURL: URL,
		using model: NSManagedObjectModel
	) -> NSPersistentContainer {
		
		let container = NSPersistentContainer(
			name: name,
			managedObjectModel: model)
		
		let description = NSPersistentStoreDescription(url: storeURL)
		container.persistentStoreDescriptions = [description]
		
		return container
	}
	
	private static func loadPersistentStore(
		for container: NSPersistentContainer,
		completion: (([(NSPersistentStoreDescription, Error?)]) -> Void)? = nil
	) throws {
		var loaded: [(NSPersistentStoreDescription, Swift.Error?)] = []
		
		container.loadPersistentStores { (store, error) in
			loaded.append((store, error))
		}
		
		completion?(loaded)
	}
}
