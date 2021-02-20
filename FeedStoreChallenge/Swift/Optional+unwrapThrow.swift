// 
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
extension Optional {
	
	public func unwrap(
		throw errorExpression: @autoclosure () -> Error? = nil,
	    inFile file: StaticString = #filePath,
		atLine line: UInt = #line
	) throws -> Wrapped {
		guard let unrwapped = self else {
			throw errorExpression() ?? UnwrapOptionalError(inFile: file, atLine: line)
		}
		
		return unrwapped
	}
}

public func Unwrap<T>(
	_ expression: @autoclosure () throws -> Optional<T>,
	throw errorExpression: @autoclosure () -> Error = UnwrapOptionalError(inFile: #filePath, atLine: #line),
	inFile file: StaticString = #filePath,
	atLine line: UInt = #line
) throws -> T {
	return try expression().unwrap(throw: errorExpression(), inFile: file, atLine: line)
}

public struct UnwrapOptionalError: Error, CustomStringConvertible {
	public let file: StaticString
	public let line: UInt
	private let message: String
	
	public var description: String {
		let path = (file.description as NSString).lastPathComponent
		return "\(message) in '\(path)', at line \(line)"
	}

	public init(
		message: String? = nil,
		inFile file: StaticString = #filePath,
		atLine line: UInt = #line
	) {
		self.message = message ?? "\(UnwrapOptionalError.self)"
		self.file = file
		self.line = line
	}
}
