import Down
import Foundation
import os.log

class MarkdownRenderer: Renderer {
	private let cssUrl = Bundle.main.url(
		forResource: "markdown-github-markdown-css.min",
		withExtension: "css"
	)

	override func getStylesheets() -> [Stylesheet] {
		var stylesheets = super.getStylesheets()
		if let cssUrl = cssUrl {
			stylesheets.append(Stylesheet(url: cssUrl))
		} else {
			os_log("Could not find Markdown stylesheet", type: .error)
		}
		return stylesheets
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
