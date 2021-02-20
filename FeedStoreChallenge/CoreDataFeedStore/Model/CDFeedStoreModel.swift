// 
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public enum CDFeedStoreModel {
	public static let name = "CDFeedStore"
	public static let modelExtension = "momd"
	public static let storeExtension = "sqlite"

	public static func modelURL() -> URL? {
		return Bundle(for: CDFeedImage.self)
			.url(forResource: name, withExtension: modelExtension)
	}
	
	public static func storeURL() -> URL? {
		return FileManager.default
			.urls(for: .applicationSupportDirectory, in: .userDomainMask)
			.first?
			.appendingPathComponent(name)
			.appendingPathExtension(storeExtension)
	}
}
