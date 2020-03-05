import Foundation
import os.log

let normalizeCssUrl = Bundle.main.url(forResource: "minireset.min", withExtension: "css")
let sharedCssUrl = Bundle.main.url(forResource: "shared", withExtension: "css")

class Renderer {
	var fileContent: String
	var fileExtension: String

	required init(fileContent: String, fileExtension: String) {
		self.fileContent = fileContent
		self.fileExtension = fileExtension
	}

	func getCss() -> String {
		var normalizeCss = ""
		var sharedCss = ""

		do {
			if let normalizeCssPath = normalizeCssUrl?.path {
				normalizeCss = try String(contentsOfFile: normalizeCssPath)
			} else {
				os_log("Cannot find normalize stylesheet", type: .error)
			}
		} catch {
			os_log("Cannot read normalize stylesheet: %s", type: .error, error.localizedDescription)
		}

		do {
			if let sharedCssPath = sharedCssUrl?.path {
				sharedCss = try String(contentsOfFile: sharedCssPath)
			} else {
				os_log("Cannot find shared stylesheet", type: .error)
			}
		} catch {
			os_log("Cannot read shared stylesheet: %s", type: .error, error.localizedDescription)
		}

		return "\(normalizeCss)\n\n\(sharedCss)"
	}

	func getHtml() throws -> String {
		""
	}

	func getJs() -> String {
		""
	}
}
