import Down
import Foundation
import os.log

class MarkdownRenderer: Renderer {
	private let cssUrl = Bundle.main.url(forResource: "markdown", withExtension: "css")

	override func getCssFiles() -> [URL] {
		var cssFiles = super.getCssFiles()
		if let cssUrlResolved = cssUrl {
			cssFiles.append(cssUrlResolved)
		} else {
			os_log("Could not find Markdown stylesheet", type: .error)
		}
		return cssFiles
	}

	override func getHtml() -> String {
		let down = Down(markdownString: fileContent)

		do {
			let html = try down.toHTML()
			return "<div class=\"markdown-body\">\(html)</div>"
		} catch {
			os_log(
				"Down could not generate HTML from Markdown: %s",
				type: .error,
				error.localizedDescription
			)
			return errorHtml
		}
	}
}
