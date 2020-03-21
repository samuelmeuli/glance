import Foundation
import os.log

class Renderer {
	/// Stylesheet with CSS that applies to all file types
	private let sharedCssUrl = Bundle.main.url(forResource: "shared-main", withExtension: "css")
	let chromaCssUrl = Bundle.main.url(forResource: "shared-chroma", withExtension: "css")

	/// HTML of error message which can be displayed instead of the file content's HTML
	/// representation
	let errorHtml = "<p>Something went wrong</p>"

	/// Information about the file to be rendered
	var fileContent: String
	var fileExtension: String
	var fileUrl: URL

	required init(fileContent: String, fileExtension: String, fileUrl: URL) {
		self.fileContent = fileContent
		self.fileExtension = fileExtension
		self.fileUrl = fileUrl
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

	func getHtml() -> String {
		""
	}

	func getScripts() -> [Script] {
		[]
	}
}
