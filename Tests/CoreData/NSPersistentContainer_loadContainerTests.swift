// 
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import CoreData
import FeedStoreChallenge

class NSPersistentContainer_loadContainerTests: XCTestCase {
	private let testModelName = "CDTestModel"
	private let modelExtension = "momd"
	private let testDirectory = FileManager
		.default
		.temporaryDirectory
		.appendingPathComponent(String(describing: NSPersistentContainer_loadContainerTests.self))

	override func tearDown() {
		super.tearDown()
		
		XCTAssertNoThrow(try removeTestDirectory())
	}
	
	func test_loadContainer_validModelUrl_returnsContainer() throws {
		let storeURL = makeValidStoreUrl()

		let container = try loadContainer(storeURL: storeURL)

		XCTAssertEqual(container.persistentStoreDescriptions.first?.url, storeURL)
	}
	
	func test_loadContainer_validModelUrl_returnsContainerWithPersistentStoreDescriptionsURL() throws {
		let storeURL = makeValidStoreUrl()

		let container = try loadContainer(storeURL: storeURL)

		XCTAssertEqual(container.persistentStoreDescriptions.count, 1)
		XCTAssertEqual(container.persistentStoreDescriptions.first?.url, storeURL)
	}
	
	func test_loadContainer_validModelUrl_loadsPersistentStoreAtURL() throws {
		let storeURL = makeValidStoreUrl()

		_ = try loadContainer(storeURL: storeURL)

		XCTAssertTrue(FileManager.default.fileExists(atPath: storeURL.path))
	}
	
	func test_loadContainer_returnsNamedContainer() throws {
		let container = try loadContainer(name: "AModelName")

		XCTAssertEqual(container.name, "AModelName")
	}
	
	func test_loadContainer_invalidModelUrl_throwsModelNotFound() {
		let invalidURL = URL(string: "file://invalid-url")!
		do {
			_ = try loadContainer(modelURL: invalidURL)
			XCTFail("expected throw")
		} catch {
			switch error as? NSPersistentContainer.LoadError {
			case let .modelNotFound(url): XCTAssertEqual(url, invalidURL)
			default: XCTFail("expected .modelNotFound, got \(error)")
			}
		}
	}
	
	// MARK: Helpers
	
	private func loadContainer(
		name: String? = nil,
		modelURL: URL? = nil,
		storeURL: URL? = nil
	) throws -> NSPersistentContainer {
		
		return try NSPersistentContainer.loadContainer(
			name: name ?? "AnyValidName",
			modelURL: modelURL ?? makeModelURL(),
			storeURL: storeURL ?? makeValidStoreUrl())
	}
	
	private func makeValidStoreUrl() -> URL {
		return testDirectory
				.appendingPathComponent(testModelName, isDirectory: false)
				.appendingPathExtension(modelExtension)
	}
	
	private func makeModelURL() -> URL {
		let bundle = Bundle(for: CDTestEntity.self)
		return bundle.url(forResource: testModelName, withExtension: modelExtension)!
	}
	
	private func removeTestDirectory() throws {
		if FileManager.default.fileExists(atPath: testDirectory.path) {
			try FileManager.default.removeItem(at: testDirectory)
		}
	}
}
