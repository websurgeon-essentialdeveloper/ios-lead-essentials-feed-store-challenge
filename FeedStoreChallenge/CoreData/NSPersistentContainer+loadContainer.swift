// 
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

extension NSPersistentContainer {
	public enum LoadError: Error {
		case modelNotFound(URL)
		case loadPersistentStoreFailed(Error)
	}
	
	public static func loadContainer(name: String, modelURL: URL, storeURL: URL) throws -> NSPersistentContainer {
		guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
			throw LoadError.modelNotFound(modelURL)
		}
		
		let container = NSPersistentContainer(
			name: name,
			managedObjectModel: model)
		
		let description = NSPersistentStoreDescription(url: storeURL)
		container.persistentStoreDescriptions = [description]
			
		var err: Swift.Error?
		container.loadPersistentStores { (_, error) in
			err = error
		}
		
		try err.map { throw LoadError.loadPersistentStoreFailed($0) }

		return container
	}
}
