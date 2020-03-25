import Foundation
import os.log
import SwiftExec

class JupyterRenderer: Renderer {
	private let mainCssUrl = Bundle.main.url(forResource: "jupyter-main", withExtension: "css")
	private let chromaCssUrl = Bundle.main.url(forResource: "shared-chroma", withExtension: "css")
	private let katexAutoRenderJsUrl = Bundle.main.url(
		forResource: "jupyter-katex-auto-render.min",
		withExtension: "js"
	)
	private let katexCssUrl = Bundle.main.url(
		forResource: "jupyter-katex.min",
		withExtension: "css"
	)
	private let katexJsUrl = Bundle.main.url(forResource: "jupyter-katex.min", withExtension: "js")
	private let nbtohtmlBinUrl = Bundle.main.url(forAuxiliaryExecutable: "nbtohtml-v0.3.0")

	override func getStylesheets() -> [Stylesheet] {
		var stylesheets = super.getStylesheets()

		// Main Jupyter stylesheet (overrides and additions for nbtohtml stylesheet)
		if let mainCssUrl = mainCssUrl {
			stylesheets.append(Stylesheet(url: mainCssUrl))
		} else {
			os_log("Could not find main Jupyter stylesheet", type: .error)
		}

		// Chroma stylesheet (for code syntax highlighting)
		if let chromaCssUrl = chromaCssUrl {
			stylesheets.append(Stylesheet(url: chromaCssUrl))
		} else {
			os_log("Could not find Chroma stylesheet", type: .error)
		}

		// KaTeX stylesheet (for rendering LaTeX math)
		if let katexCssUrl = katexCssUrl {
			stylesheets.append(Stylesheet(url: katexCssUrl))
		} else {
			os_log("Could not find KaTeX stylesheet", type: .error)
		}

		return stylesheets
	}

	override func getHtml() throws -> String {
		guard let nbtohtmlBinUrl = nbtohtmlBinUrl else {
			os_log("Could not find nbtohtml binary", type: .error)
			throw RendererError.resourceNotFoundError(resourceName: "nbtohtml binary")
		}

		do {
			let result = try exec(
				program: nbtohtmlBinUrl.path,
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
		if let katexJsUrl = katexJsUrl {
			scripts.append(Script(url: katexJsUrl))
		} else {
			os_log("Could not find KaTeX script", type: .error)
		}

		// KaTeX auto-renderer (finds LaTeX math ond the page and calls KaTeX on it)
		if let katexAutoRenderJsUrl = katexAutoRenderJsUrl {
			scripts.append(Script(url: katexAutoRenderJsUrl))
		} else {
			os_log("Could not find KaTeX auto-render script", type: .error)
		}

		// Main script (calls the KaTeX auto-renderer)
		scripts.append(Script(content: """
			renderMathInElement(document.body);
		"""))

		return scripts
	}
}
