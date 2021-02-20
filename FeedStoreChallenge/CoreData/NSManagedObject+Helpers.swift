// 
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
	static func entityName() -> String {
		return entity().name!
	}
}
