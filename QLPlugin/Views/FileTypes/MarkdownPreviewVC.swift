import Down
import Foundation
import os.log

class MarkdownPreviewVC: WebPreviewVC {
	private let githubMarkdownCSSURL = Bundle.main.url(
		forResource: "markdown-main",
		withExtension: "css"
	)

	override func getStylesheets() -> [Stylesheet] {
		var stylesheets = super.getStylesheets()
		if let cssURL = githubMarkdownCSSURL {
			stylesheets.append(Stylesheet(url: cssURL))
		} else {
			os_log("Could not find `github-markdown-css` stylesheet", log: Log.render, type: .error)
		}
		return stylesheets
	}

	override func getHTML() throws -> String {
		var fileContent: String
		do {
			fileContent = try file.read()
		} catch {
			os_log(
				"Could not read Markdown file: %{public}s",
				log: Log.parse,
				type: .error,
				error.localizedDescription
			)
			throw error
		}

		let down = Down(markdownString: fileContent)

		do {
			let html = try down.toHTML()
			return "<div class=\"markdown-body\">\(html)</div>"
		} catch {
			os_log(
				"Down could not generate HTML from Markdown: %{public}s",
				log: Log.render,
				type: .error,
				error.localizedDescription
			)
			throw error
		}
	}
}
