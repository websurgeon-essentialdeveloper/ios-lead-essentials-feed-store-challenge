// 
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class Optional_unwrapThrowTests: XCTestCase {
	private typealias SUT = Optional<CustomWrappedType>
	
	func test_unwrap_whenNil_errorIncludesFileDefault() {
		let sut: SUT? = nil
		
		assertThrowsUnwrapOptionalError(
			try sut.unwrap()
		) {
			XCTAssertEqual($0.file.description, #file.description)
		}
	}
	
	func test_unwrap_whenNil_errorIncludesFile() {
		let sut: SUT? = nil
		
		assertThrowsUnwrapOptionalError(
			try sut.unwrap(inFile: "any/file/location")
		) {
			XCTAssertEqual($0.file.description, "any/file/location")
		}
	}
	
	func test_unwrap_whenNil_errorIncludesLine() {
		let sut: SUT? = nil
		
		assertThrowsUnwrapOptionalError(
			try sut.unwrap(atLine: 123)
		) {
			XCTAssertEqual($0.line, 123)
		}
	}
	
	func test_unwrap_whenNil_errorIncludesLineDefault() {
		let sut: SUT? = nil
		
		assertThrowsUnwrapOptionalError(
			try sut.unwrap()
		) {
			XCTAssertEqual($0.line, #line - 2)
		}
	}
	
	func test_unwrap_whenNilAndCustomErrorProvided_shouldThrowCustomError() {
		let sut: SUT? = nil
		let expectedError = CustomTestError()
		
		assertThrowsError(CustomTestError.self,
			try sut.unwrap(throw: expectedError)
		) {
			XCTAssertEqual($0, expectedError)
		}
	}
	
	func test_unwrap_returnsWrappedValue() {
		let value = CustomWrappedType()
		let sut: SUT? = Optional.some(value)
		
		XCTAssertEqual(try sut.unwrap(), value)
	}
	
	func test_UnwrapFunction_unwrapping() throws {
		let value = CustomWrappedType()
		let sut: SUT? = Optional.some(value)
		
		XCTAssertEqual(try Unwrap(sut), value)
	}
	
	func test_UnwrapFunction_throws() {
		let sut: SUT? = nil
		let expectedError = CustomTestError()
		
		assertThrowsError(CustomTestError.self,
			try Unwrap(sut, throw: expectedError)
		) {
			XCTAssertEqual($0, expectedError)
		}
	}
	
	// MARK: Helpers
	
	private func assertThrowsUnwrapOptionalError<T>(
		_ expression: @autoclosure () throws -> T,
		inFile file: StaticString = #filePath,
		atLine line: UInt = #line,
		completion: ((UnwrapOptionalError) -> Void)? = nil
	) {
		assertThrowsError(UnwrapOptionalError.self,
					try expression(),
					inFile: file,
					atLine: line,
					completion: completion)
	}
	
	private func assertThrowsError<E: Error, T>(
		_ errorType: E.Type,
		_ expression: @autoclosure () throws -> T,
		inFile file: StaticString = #filePath,
		atLine line: UInt = #line,
		completion: ((E) -> Void)? = nil) {
		do {
			let value = try expression()
			XCTFail("expected error, got unwrapped \(value)", file: file, line: line)
		} catch let error as E {
			completion?(error)
		} catch {
			XCTFail("expected \(E.self), got \(type(of: error))", file: file, line: line)
		}
	}
	
	private struct CustomWrappedType: Equatable {}
	
	private struct CustomTestError: Error, Equatable {}
}
