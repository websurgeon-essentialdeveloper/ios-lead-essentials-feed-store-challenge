// 
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
	public typealias Model = CDFeedStoreModel
	public typealias LoadedStoresCompletion = NSPersistentContainer.LoadedStoresCompletion
	
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext
	
	public enum Error: Swift.Error {
		case invalidModelURL
		case invalidStoreURL
		case modelNotFound(URL)
		case loadPersistentStoresFailed([NSPersistentContainer.StoreLoadFailure])
		case unhandled(Swift.Error?)
	}

	public init(
		name: String = Model.name,
		modelURL: URL? = Model.modelURL(),
		storeURL: URL? = Model.storeURL(),
		loadedStores: LoadedStoresCompletion? = nil
	) throws {
		do {
			container = try NSPersistentContainer.loadContainer(
				name: name,
				modelURL: try modelURL.unwrap(throw: Error.invalidModelURL),
				storeURL: try storeURL.unwrap(throw: Error.invalidStoreURL),
				loadedStores: loadedStores)
			
			context = container.newBackgroundContext()
		} catch {
			throw Self.transformError(error)
		}
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		
	}
	
	public func insert(
		_ feed: [LocalFeedImage],
		timestamp: Date,
		completion: @escaping InsertionCompletion
	) {
		context.perform {
			let toCDFeedImage = CDFeedImage.fromLocalFeed(in: self.context)
			
			do {
				let cache = try self.context.find(CDFeedCache.self)?.first ?? CDFeedCache(context: self.context)
				cache.timestamp = timestamp

				let images: [CDFeedImage] = feed.map(toCDFeedImage)

				cache.images = NSOrderedSet(array: images)

				try self.context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}

	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		context.perform {
			if let cache = try? self.context.find(CDFeedCache.self)?.first,
			   let images = cache.images {
				let feed = images
					.compactMap { ($0 as? CDFeedImage)?.toLocalFeedImage() }
				
				completion(.found(feed: feed, timestamp: cache.timestamp!))
			} else {
				completion(.empty)
			}
		}
	}
	
	private static func transformError(_ anyError: Swift.Error) -> Error {
		if let error = anyError as? Error {
			return error
		} else {
			return Error.unhandled(anyError)
		}
	}
}

