//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class FeedStoreIntegrationTests: XCTestCase {
	
	//  ***********************
	//
	//  Uncomment and implement the following tests if your
	//  implementation persists data to disk (e.g., CoreData/Realm)
	//
	//  ***********************
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		try setupEmptyStoreState()
	}
	
	override func tearDownWithError() throws {
		try undoStoreSideEffects()
		
		try super.tearDownWithError()
	}
	
	func test_retrieve_deliversEmptyOnEmptyCache() throws {
		let sut = try makeSUT()

		expect(sut, toRetrieve: .empty)
	}
	
	func test_retrieve_deliversFeedInsertedOnAnotherInstance() throws {
		let storeToInsert = try makeSUT()
		let storeToLoad = try makeSUT()
		let feed = uniqueImageFeed()
		let timestamp = Date()

		insert((feed, timestamp), to: storeToInsert)

		expect(storeToLoad, toRetrieve: .found(feed: feed, timestamp: timestamp))
	}
	
	func test_insert_overridesFeedInsertedOnAnotherInstance() throws {
		let storeToInsert = try makeSUT()
		let storeToOverride = try makeSUT()
		let storeToLoad = try makeSUT()

		insert((uniqueImageFeed(), Date()), to: storeToInsert)

		let latestFeed = uniqueImageFeed()
		let latestTimestamp = Date()
		insert((latestFeed, latestTimestamp), to: storeToOverride)

		expect(storeToLoad, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
	}
	
	func test_delete_deletesFeedInsertedOnAnotherInstance() throws {
		let storeToInsert = try makeSUT()
		let storeToDelete = try makeSUT()
		let storeToLoad = try makeSUT()

		insert((uniqueImageFeed(), Date()), to: storeToInsert)

		deleteCache(from: storeToDelete)

		expect(storeToLoad, toRetrieve: .empty)
	}
	
	// - MARK: Helpers
	
	private func makeSUT(
		file: StaticString = #filePath, line: UInt = #line
	) throws -> FeedStore {
		let sut = try CoreDataFeedStore(
			name: storeName(),
			modelURL: CDFeedStoreModel.modelURL(),
			storeURL: storeURL(name: storeName())
		) { loaded in
			XCTAssertEqual(loaded.count, 1, file: file, line: line)
			XCTAssertNil(loaded.first?.error, file: file, line: line)
		}
		
		trackForMemoryLeaks(sut)

		return sut
	}
	
	private func setupEmptyStoreState() throws {
		try clearArtifactsDirectory()
	}
	
	private func undoStoreSideEffects() throws {
		try clearArtifactsDirectory()
	}
	
	private func clearArtifactsDirectory() throws {
		if FileManager.default.fileExists(atPath: artifactsDirectory().path) {
			try FileManager.default.removeItem(at: artifactsDirectory())
		}
	}
	
	private func artifactsDirectory() -> URL {
		return FileManager.default
			.urls(for: .cachesDirectory, in: .userDomainMask)
			.first!
			.appendingPathComponent("\(FeedStoreIntegrationTests.self)")
	}

	private func storeName() -> String {
		return "\(FeedStoreIntegrationTests.self)Store"
	}
	
	private func storeURL(name: String) -> URL {
		return artifactsDirectory()
			.appendingPathComponent(name)
	}
	
}
