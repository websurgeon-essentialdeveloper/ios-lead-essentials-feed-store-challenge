// 
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {

	func find<T: NSManagedObject>(_ type: T.Type) throws -> [T]? {
		let request = NSFetchRequest<T>(entityName: T.entityName())
				
		return try? fetch(request)
	}
}
