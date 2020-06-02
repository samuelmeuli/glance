import Foundation
import os.log

let dotfileLexers = [
	// Files with syntax supported by Chroma
	".bashrc": ".bashrc",
	".vimrc": ".vimrc",
	".zprofile": "zsh",
	".zshrc": ".zshrc",
	"dockerfile": "Dockerfile",
	"gemfile": "Gemfile",
	"gnumakefile": "Makefile",
	"makefile": "Makefile",
	"pkgbuild": "PKGBUILD",
	"rakefile": "Rakefile",

	// Files for which a different, similar syntax is used
	".dockerignore": "bash",
	".editorconfig": "ini",
	".gitattributes": "bash",
	".gitconfig": "ini",
	".gitignore": "bash",
	".npmignore": "bash",
	".zsh_history": "txt",
]

let fileExtensionLexers = [
	// Files with syntax supported by Chroma
	"alfredappearance": "json",
	"cls": "tex",
	"entitlements": "xml",
	"hbs": "handlebars",
	"iml": "xml",
	"plist": "xml",
	"resolved": "json",
	"scpt": "applescript",
	"scptd": "applescript",
	"spf": "xml",
	"spTheme": "xml",
	"storyboard": "xml",
	"stringsdict": "xml",
	"sty": "tex",
	"webmanifest": "json",
	"xcscheme": "xml",
	"xib": "xml",

	// Files for which a different, similar syntax is used
	"liquid": "twig",
	"modulemap": "hcl",
	"njk": "twig",
	"pbxproj": "txt",
	"strings": "c",
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
		} else if fileURL.pathExtension.lowercased() == "dist" {
			// .dist file
			return getLexer(fileURL: fileURL.deletingPathExtension())
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
