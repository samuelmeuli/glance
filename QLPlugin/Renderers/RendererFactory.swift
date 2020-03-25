import Foundation

/// Returns an instance of the `Renderer` subclass that should be used for the provided file type
class RendererFactory {
	static func getRenderer(file: File) -> Renderer {
		var renderer: Renderer.Type

		switch file.url.pathExtension {
		case "csv", "tab", "tsv":
			renderer = CsvRenderer.self
		case "md", "markdown", "mdown", "mkdn", "mkd":
			renderer = MarkdownRenderer.self
		case "ipynb":
			renderer = JupyterRenderer.self
		default:
			renderer = CodeRenderer.self
		}

		return renderer.init(file: file)
	}
}
