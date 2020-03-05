import Foundation

class RendererFactory {
	static func getRenderer(fileContent: String, fileExtension: String) -> Renderer {
		switch fileExtension {
		case "md", "markdown", "mdown", "mkdn", "mkd":
			return MarkdownRenderer(fileContent: fileContent, fileExtension: fileExtension)
		default:
			return CodeRenderer(fileContent: fileContent, fileExtension: fileExtension)
		}
	}
}
