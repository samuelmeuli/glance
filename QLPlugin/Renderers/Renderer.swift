import Foundation
import os.log

enum RendererError {
	case resourceNotFoundError(resourceName: String)
}

extension RendererError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case let .resourceNotFoundError(resourceName):
			return NSLocalizedString(
				"Could not find renderer resource \"\(resourceName)\"",
				comment: ""
			)
		}
	}
}

class Renderer {
	/// Stylesheet with CSS that applies to all file types
	private let sharedCssUrl = Bundle.main.url(forResource: "shared-main", withExtension: "css")

	/// File to be rendered
	var file: File

	required init(file: File) {
		self.file = file
	}

	func getStylesheets() -> [Stylesheet] {
		var stylesheets: [Stylesheet] = []

		if let sharedCssUrl = sharedCssUrl {
			stylesheets.append(Stylesheet(url: sharedCssUrl))
		} else {
			os_log("Could not find shared stylesheet", type: .error)
		}

		return stylesheets
	}

	func getHtml() throws -> String { "" }

	func getScripts() throws -> [Script] { [] }
}
