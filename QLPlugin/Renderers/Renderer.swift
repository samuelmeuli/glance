import Foundation
import os.log

class Renderer {
	private let normalizeCssUrl = Bundle.main.url(
		forResource: "minireset.min",
		withExtension: "css"
	)
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

	func getCssFiles() -> [URL] {
		var cssFiles: [URL] = []

		if let normalizeCssUrlResolved = normalizeCssUrl {
			cssFiles.append(normalizeCssUrlResolved)
		} else {
			os_log("Could not find normalize stylesheet", type: .error)
		}

		if let sharedCssUrlResolved = sharedCssUrl {
			cssFiles.append(sharedCssUrlResolved)
		} else {
			os_log("Could not find shared stylesheet", type: .error)
		}

		return cssFiles
	}

	func getHtml() -> String {
		""
	}

	func getJsFiles() -> [URL] {
		[]
	}
}
