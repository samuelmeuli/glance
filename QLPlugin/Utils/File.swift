import Foundation

enum FileError: Error {
	case fileAttributeError(path: String, message: String)
	case fileNotFoundError(path: String)
	case fileReadError(path: String, message: String)
}

extension FileError: LocalizedError {
	public var errorDescription: String? {
		switch self {
			case let .fileAttributeError(path, message):
				return NSLocalizedString(
					"Could not get attributes for file at path \(path): \(message)",
					comment: ""
				)
			case let .fileNotFoundError(path):
				return NSLocalizedString("Could not find file at path \(path)", comment: "")
			case let .fileReadError(path, message):
				return NSLocalizedString(
					"Could not read file at path \(path): \(message)",
					comment: ""
				)
		}
	}
}

/// Utility class for reading the content and metadata of the corresponding file
class File {
	let archiveExtensions = ["tar", "tar.gz", "zip"]
	let fileManager = FileManager.default

	var attributes: [FileAttributeKey: Any]
	var isDirectory: Bool
	var path: String
	var url: URL

	var isArchive: Bool { archiveExtensions.contains(url.pathExtension) }
	var size: UInt64 { attributes[.size] as? UInt64 ?? UInt64(0) }

	/// Looks for a file at the provided URL and saves its metadata as object properties
	init(url: URL) throws {
		self.url = url
		path = url.path

		// Check whether the provided URL points to a directory
		var isDirectoryObjC: ObjCBool = false
		guard fileManager.fileExists(atPath: path, isDirectory: &isDirectoryObjC) else {
			throw FileError.fileNotFoundError(path: path)
		}
		isDirectory = isDirectoryObjC.boolValue

		// Read file attributes (e.g. file size)
		do {
			attributes = try fileManager.attributesOfItem(atPath: path)
		} catch let error as NSError {
			throw FileError.fileAttributeError(path: path, message: error.localizedDescription)
		}
	}

	/// Reads and returns the file's content as an UTF-8 string
	func read() throws -> String {
		do {
			return try String(contentsOf: url, encoding: .utf8)
		} catch {
			throw FileError.fileReadError(path: path, message: error.localizedDescription)
		}
	}
}
