// 
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {

	func findOne<T: NSManagedObject>(_ type: T.Type, create: Bool = false) throws -> T? {
		let request = NSFetchRequest<T>(entityName: T.entityName())
				
		if let cache = try fetch(request).first {
			return cache
		} else {
			return create ? T(context: self) : nil
		}

	}
	
	func findOneOrCreate<T: NSManagedObject>(_ type: T.Type) throws -> T {
		return try findOne(type, create: true).unwrap()
	}
}
