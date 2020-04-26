import Foundation
import os.log

let dotfileLexers = [
	".dockerignore": "bash",
	".editorconfig": "ini",
	".gitattributes": "bash",
	".gitignore": "bash",
	".npmignore": "bash",
]

let fileExtensionLexers = [
	"alfredappearance": "json", // Alfred theme
	"cls": "tex", // LaTeX classes file
	"entitlements": "xml",
	"iml": "xml",
	"plist": "xml",
	"resolved": "json", // Swift Package Manager lockfile (Package.resolved)
	"sty": "tex", // LaTeX styles file
]

class CodePreview: Preview {
	private let chromaStylesheetURL = Bundle.main.url(
		forResource: "shared-chroma",
		withExtension: "css"
	)

	required init() {}

	/// Returns the name of the Chroma lexer to use for the file. This is determined based on the
	/// file name/extension.
	private func getLexer(fileURL: URL) -> String {
		if fileURL.pathExtension.isEmpty {
			// Dotfile
			return dotfileLexers[fileURL.lastPathComponent, default: "autodetect"]
		} else {
			// File with extension
			return fileExtensionLexers[fileURL.pathExtension, default: "autodetect"]
		}
	}

	private func getHTML(file: File) throws -> String {
		var source: String
		do {
			source = try file.read()
		} catch {
			os_log(
				"Could not read code file: %{public}s",
				log: Log.parse,
				type: .error,
				error.localizedDescription
			)
			throw error
		}

		let lexer = getLexer(fileURL: file.url)
		do {
			return try HTMLRenderer.renderCode(source, lexer: lexer)
		} catch {
			os_log(
				"Could not generate code HTML: %{public}s",
				log: Log.render,
				type: .error,
				error.localizedDescription
			)
			throw error
		}
	}

	private func getStylesheets() -> [Stylesheet] {
		var stylesheets = [Stylesheet]()

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
