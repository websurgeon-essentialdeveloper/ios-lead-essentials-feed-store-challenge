// 
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class Optional_unwrapThrowTests: XCTestCase {
	private typealias SUT = Optional<CustomWrappedType>
	
	func test_unwrap_whenNil_errorIncludesFileDefault() {
		let sut: SUT? = nil
		
		do {
			_ = try sut.unwrap()
		} catch let error as UnwrapOptionalError {
			XCTAssertEqual(error.file.description, #file.description)
		} catch {
			XCTFail("expected Optional.UnwrappingError, got \(type(of: error))")
		}
	}
	
	func test_unwrap_whenNil_errorIncludesFile() {
		let sut: SUT? = nil
		
		do {
			_ = try sut.unwrap(inFile: "any/file/location")
		} catch let error as UnwrapOptionalError {
			XCTAssertEqual(error.file.description, "any/file/location")
		} catch {
			XCTFail("expected Optional.UnwrappingError, got \(type(of: error))")
		}
	}
	
	func test_unwrap_whenNil_errorIncludesLine() {
		let sut: SUT? = nil
		
		do {
			_ = try sut.unwrap(atLine: 123)
		} catch let error as UnwrapOptionalError {
			XCTAssertEqual(error.line, 123)
		} catch {
			XCTFail("expected Optional.UnwrappingError, got \(type(of: error))")
		}
	}
	
	func test_unwrap_whenNil_errorIncludesLineDefault() {
		let sut: SUT? = nil
		
		do {
			_ = try sut.unwrap()
		} catch let error as UnwrapOptionalError {
			XCTAssertEqual(error.line, #line - 2)
		} catch {
			XCTFail("expected \(UnwrapOptionalError.self), got \(type(of: error))")
		}
	}
	
	func test_unwrap_whenNilAndCustomErrorProvided_shouldThrowCustomError() {
		let sut: SUT? = nil
		let expectedError = CustomTestError()
		
		do {
			_ = try sut.unwrap(throw: expectedError)
		} catch let error as CustomTestError {
			XCTAssertEqual(error, expectedError)
		} catch {
			XCTFail("expected \(CustomTestError.self), got \(type(of: error))")
		}
	}

	
	func test_unwrap_returnsWrappedValue() {
		let value = CustomWrappedType()
		let sut: SUT? = Optional.some(value)
		
		do {
			let unwrapped = try sut.unwrap(atLine: 123)
			XCTAssertEqual(unwrapped, value)
		}  catch {
			XCTFail("expected unwrapped value, got '(error)")
		}
	}
	
	private struct CustomWrappedType: Equatable {}
	
	private struct CustomTestError: Error, Equatable {}
}
