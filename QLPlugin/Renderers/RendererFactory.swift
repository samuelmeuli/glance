import Foundation

class RendererFactory {
	static func getRenderer(
		fileContent: String,
		fileExtension: String,
		fileUrl: URL
	) -> Renderer {
		var renderer: Renderer.Type
		switch fileExtension {
		case "md", "markdown", "mdown", "mkdn", "mkd":
			renderer = MarkdownRenderer.self
		default:
			renderer = CodeRenderer.self
		}

		return renderer.init(
			fileContent: fileContent,
			fileExtension: fileExtension,
			fileUrl: fileUrl
		)
	}
}
