// 
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

extension CDFeedImage {
	func toLocalFeedImage() -> LocalFeedImage {
		return LocalFeedImage(
			id: id,
			description: imageDescription,
			location: location,
			url: url)
	}
	
	static func fromLocalFeed(in context: NSManagedObjectContext) -> (LocalFeedImage) -> CDFeedImage {
		return {
			let image = CDFeedImage(context: context)
			image.id = $0.id
			image.imageDescription = $0.description
			image.url = $0.url
			image.location = $0.location
			
			return image
		}
	}
}
