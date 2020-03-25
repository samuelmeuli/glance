import Down
import Foundation
import os.log

class MarkdownRenderer: Renderer {
	private let githubMarkdownCssUrl = Bundle.main.url(
		forResource: "markdown-main",
		withExtension: "css"
	)

	override func getStylesheets() -> [Stylesheet] {
		var stylesheets = super.getStylesheets()
		if let cssUrl = githubMarkdownCssUrl {
			stylesheets.append(Stylesheet(url: cssUrl))
		} else {
			os_log("Could not find `github-markdown-css` stylesheet", type: .error)
		}
		return stylesheets
	}

	override func getHtml() throws -> String {
		var fileContent: String
		do {
			fileContent = try file.read()
		} catch {
			os_log("Could not read Markdown file: %s", type: .error, error.localizedDescription)
			throw error
		}

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
			throw error
		}
	}
}
