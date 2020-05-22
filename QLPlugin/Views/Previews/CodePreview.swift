import Foundation
import os.log

let dotfileLexers = [
	".bashrc": "bashrc",
	".dockerignore": "bash",
	".editorconfig": "ini",
	".gitattributes": "bash",
	".gitconfig": "ini",
	".gitignore": "bash",
	".npmignore": "bash",
	".vimrc": "vim",
	".zprofile": "zsh",
	".zsh_history": "txt",
	".zshrc": "zshrc",
	"dockerfile": "Dockerfile",
	"gemfile": "Gemfile",
	"gnumakefile": "Makefile",
	"makefile": "Makefile",
	"pkgbuild": "pkgbuild",
	"rakefile": "Rakefile",
]

let fileExtensionLexers = [
	"alfredappearance": "json", // Alfred theme
	"cls": "tex", // LaTeX classes file
	"entitlements": "xml",
	"hbs": "handlebars", // Handlebars template
	"iml": "xml",
	"liquid": "twig", // Liquid template
	"njk": "twig", // Nunjucks template
	"plist": "xml",
	"resolved": "json", // Swift Package Manager lockfile (Package.resolved)
	"scpt": "applescript", // AppleScript binary
	"scptd": "applescript", // AppleScript bundle
	"spf": "xml", // Sequel Pro query favorites file
	"spTheme": "xml", // Sequel Pro theme file
	"sty": "tex", // LaTeX styles file
	"webmanifest": "json", // Web app manifest
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
			return dotfileLexers[fileURL.lastPathComponent.lowercased(), default: "autodetect"]
		} else {
			// File with extension
			return fileExtensionLexers[
				fileURL.pathExtension.lowercased(),
				default: fileURL.pathExtension
			]
		}
	}

	func getSource(file: File) throws -> String {
		try file.read()
	}

	private func getHTML(file: File) throws -> String {
		var source: String
		do {
			source = try getSource(file: file)
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
