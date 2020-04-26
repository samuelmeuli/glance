import Foundation
import os.log

class MarkdownPreview: Preview {
	private let chromaStylesheetURL = Bundle.main.url(
		forResource: "shared-chroma",
		withExtension: "css"
	)
	private let mainStylesheetURL = Bundle.main.url(
		forResource: "markdown-main",
		withExtension: "css"
	)

	required init() {}

	private func getHTML(file: File) throws -> String {
		var source: String
		do {
			source = try file.read()
		} catch {
			os_log(
				"Could not read Markdown file: %{public}s",
				log: Log.parse,
				type: .error,
				error.localizedDescription
			)
			throw error
		}

		do {
			let html = try HTMLRenderer.renderMarkdown(source)
			return "<div class=\"markdown-body\">\(html)</div>"
		} catch {
			os_log(
				"Could not generate Markdown HTML: %{public}s",
				log: Log.render,
				type: .error,
				error.localizedDescription
			)
			throw error
		}
	}

	private func getStylesheets() -> [Stylesheet] {
		var stylesheets = [Stylesheet]()

		// Main Markdown stylesheet
		if let mainStylesheetURL = mainStylesheetURL {
			stylesheets.append(Stylesheet(url: mainStylesheetURL))
		} else {
			os_log("Could not find main Markdown stylesheet", log: Log.render, type: .error)
		}

		// Chroma stylesheet (for code syntax highlighting)
		if let chromaStylesheetURL = chromaStylesheetURL {
			stylesheets.append(Stylesheet(url: chromaStylesheetURL))
		} else {
			os_log("Could not find Chroma stylesheet", log: Log.render, type: .error)
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
