import Foundation
import os.log
import SwiftExec

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

class CodeRenderer: Renderer {
	private let chromaBinUrl = Bundle.main.url(forAuxiliaryExecutable: "chroma-v0.7.0")

	/// Returns the name of the Chroma lexer to use for the file. This is determined based on the
	/// file name/extension
	private func getLexer() -> String {
		if fileExtension.isEmpty {
			// Dotfile
			return dotfileLexers[fileUrl.lastPathComponent, default: "autodetect"]
		} else {
			// File with extension
			return fileExtensionLexers[fileExtension, default: "autodetect"]
		}
	}

	override func getStylesheets() -> [Stylesheet] {
		var stylesheets = super.getStylesheets()
		if let cssUrl = chromaCssUrl {
			stylesheets.append(Stylesheet(url: cssUrl))
		} else {
			os_log("Could not find Chroma stylesheet", type: .error)
		}
		return stylesheets
	}

	override func getHtml() -> String {
		guard let chromaBinUrl = chromaBinUrl else {
			os_log("Could not find Chroma binary", type: .error)
			return errorHtml
		}

		do {
			let result = try exec(
				program: chromaBinUrl.path,
				arguments: [fileUrl.path, "--html", "--html-only", "--lexer", getLexer()]
			)
			return result.stdout ?? ""
		} catch {
			os_log(
				"Error trying to convert source code to HTML using Chroma: %s",
				type: .error,
				error.localizedDescription
			)
			return errorHtml
		}
	}
}
