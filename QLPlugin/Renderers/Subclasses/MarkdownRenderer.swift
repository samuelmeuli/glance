import Down
import Foundation

class MarkdownRenderer: Renderer {
	override func getHtml() throws -> String {
		let down = Down(markdownString: fileContent)
		return try down.toHTML()
	}
}
