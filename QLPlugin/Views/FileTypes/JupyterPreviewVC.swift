import Foundation
import os.log
import SwiftExec

class JupyterPreviewVC: WebPreviewVC {
	private let mainCSSURL = Bundle.main.url(forResource: "jupyter-main", withExtension: "css")
	private let chromaCSSURL = Bundle.main.url(forResource: "shared-chroma", withExtension: "css")
	private let katexAutoRenderJSURL = Bundle.main.url(
		forResource: "jupyter-katex-auto-render.min",
		withExtension: "js"
	)
	private let katexCSSURL = Bundle.main.url(
		forResource: "jupyter-katex.min",
		withExtension: "css"
	)
	private let katexJSURL = Bundle.main.url(forResource: "jupyter-katex.min", withExtension: "js")
	private let nbtohtmlBinaryURL = Bundle.main.url(forAuxiliaryExecutable: "nbtohtml-v0.4.0")

	override func getStylesheets() -> [Stylesheet] {
		var stylesheets = super.getStylesheets()

		// Main Jupyter stylesheet (overrides and additions for nbtohtml stylesheet)
		if let mainCSSURL = mainCSSURL {
			stylesheets.append(Stylesheet(url: mainCSSURL))
		} else {
			os_log("Could not find main Jupyter stylesheet", type: .error)
		}

		// Chroma stylesheet (for code syntax highlighting)
		if let chromaCSSURL = chromaCSSURL {
			stylesheets.append(Stylesheet(url: chromaCSSURL))
		} else {
			os_log("Could not find Chroma stylesheet", type: .error)
		}

		// KaTeX stylesheet (for rendering LaTeX math)
		if let katexCSSURL = katexCSSURL {
			stylesheets.append(Stylesheet(url: katexCSSURL))
		} else {
			os_log("Could not find KaTeX stylesheet", type: .error)
		}

		return stylesheets
	}

	override func getHTML() throws -> String {
		guard let nbtohtmlBinaryURL = nbtohtmlBinaryURL else {
			os_log("Could not find nbtohtml binary", type: .error)
			throw PreviewVCError.resourceNotFoundError(resourceName: "nbtohtml binary")
		}

		do {
			let result = try exec(
				program: nbtohtmlBinaryURL.path,
				arguments: ["convert", file.path]
			)
			return result.stdout ?? ""
		} catch {
			os_log(
				"Error trying to convert Jupyter Notebook to HTML using nbtohtml: %s",
				type: .error,
				error.localizedDescription
			)
			throw error
		}
	}

	override func getScripts() throws -> [Script] {
		var scripts = try! super.getScripts()

		// KaTeX library (for rendering LaTeX math)
		if let katexJSURL = katexJSURL {
			scripts.append(Script(url: katexJSURL))
		} else {
			os_log("Could not find KaTeX script", type: .error)
		}

		// KaTeX auto-renderer (finds LaTeX math ond the page and calls KaTeX on it)
		if let katexAutoRenderJSURL = katexAutoRenderJSURL {
			scripts.append(Script(url: katexAutoRenderJSURL))
		} else {
			os_log("Could not find KaTeX auto-render script", type: .error)
		}

		// Main script (calls the KaTeX auto-renderer)
		scripts.append(Script(content: "renderMathInElement(document.body);"))

		return scripts
	}
}
