import Down
import Foundation
import os.log

class MarkdownPreview: Preview {
	private let mainStylesheetURL = Bundle.main.url(
		forResource: "markdown-main",
		withExtension: "css"
	)

	required init() {}

	private func getHTML(file: File) throws -> String {
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
				"Could not generate Markdown HTML using Down: %{public}s",
				log: Log.render,
				type: .error,
				error.localizedDescription
			)
			throw error
		}
	}

	private func getStylesheets() -> [Stylesheet] {
		var stylesheets = [Stylesheet]()

		if let mainStylesheetURL = mainStylesheetURL {
			stylesheets.append(Stylesheet(url: mainStylesheetURL))
		} else {
			os_log("Could not find main Markdown stylesheet", log: Log.render, type: .error)
		}

		return stylesheets
	}

	func createPreviewVC(file: File) throws -> PreviewVC {
		WebPreviewVC(
			html: try getHTML(file: file),
			stylesheets: getStylesheets()
		)
	}
}
