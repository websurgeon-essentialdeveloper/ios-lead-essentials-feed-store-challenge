// 
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {

	func findOne<T: NSManagedObject>(_ type: T.Type) throws -> T? {
		let request = NSFetchRequest<T>(entityName: T.entityName())
		
		return try fetch(request).first
	}
	
	func findOneOrCreate<T: NSManagedObject>(_ type: T.Type) throws -> T {
		return try findOne(type) ?? T(context: self)
	}
}
