import Cocoa
import Foundation
import os.log

enum PreviewVCError {
	case resourceNotFoundError(resourceName: String)
}

extension PreviewVCError: LocalizedError {
	public var errorDescription: String? {
		switch self {
			case let .resourceNotFoundError(resourceName):
				return NSLocalizedString(
					"Could not find preview resource \"\(resourceName)\"",
					comment: ""
				)
		}
	}
}

protocol PreviewVC: NSViewController {
	/// File to render
	var file: File { get }

	init(file: File)

	/// Reads the file content and renders it in the view controller
	func loadPreview() throws
}
