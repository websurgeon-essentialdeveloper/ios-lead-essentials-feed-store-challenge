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
		perform(in: context) { context in
			do {
				if let cache = try context.findOne(CDFeedCache.self) {
					context.delete(cache)
					try? context.save()
					completion(nil)
				} else {
					completion(nil)
				}
			} catch {
				completion(Self.transformError(error))
			}
		}
	}
	
	public func insert(
		_ feed: [LocalFeedImage],
		timestamp: Date,
		completion: @escaping InsertionCompletion
	) {
		perform(in: context) { context in
			let toCDFeedImage = CDFeedImage.fromLocalFeed(in: context)
			
			do {
				let cache = try context.findOneOrCreate(CDFeedCache.self)
				cache.timestamp = timestamp

				let images: [CDFeedImage] = feed.map(toCDFeedImage)

				cache.images = NSOrderedSet(array: images)

				try context.save()
				completion(nil)
			} catch {
				completion(Self.transformError(error))
			}
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		perform(in: context) { context in
			do {
				if let cache = try context.findOne(CDFeedCache.self),
				   let images = cache.images {
					let feed = images
						.compactMap { ($0 as? CDFeedImage)?.toLocalFeedImage() }
					
					completion(.found(feed: feed, timestamp: cache.timestamp!))
				} else {
					completion(.empty)
				}
			} catch {
				completion(.failure(Self.transformError(error)))
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
	
	func perform(
		in context: NSManagedObjectContext,
		_ block: @escaping (NSManagedObjectContext) -> Void
	) {
		context.perform { block(context) }
	}
}

