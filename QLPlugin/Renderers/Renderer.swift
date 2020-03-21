import Foundation
import os.log

class Renderer {
	private let sharedCssUrl = Bundle.main.url(forResource: "shared", withExtension: "css")

	let errorHtml = "<p>Something went wrong</p>"

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
