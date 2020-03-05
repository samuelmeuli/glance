import Foundation

enum FileInfoError: Error {
	case fileAttributeError(message: String)
	case fileReadError(message: String)
}

class FileInfo {
	var attributes: [FileAttributeKey: Any]
	var path: String
	var url: URL

	init(url: URL) throws {
		self.url = url
		path = url.path

		do {
			attributes = try FileManager.default.attributesOfItem(atPath: path)
		} catch let error as NSError {
			throw FileInfoError.fileAttributeError(message: error.localizedDescription)
		}
	}

	func getContent() throws -> String {
		do {
			return try String(contentsOf: url, encoding: .utf8)
		} catch {
			throw FileInfoError.fileReadError(message: error.localizedDescription)
		}
	}

	func getSize() -> UInt64 {
		attributes[.size] as? UInt64 ?? UInt64(0)
	}
}
