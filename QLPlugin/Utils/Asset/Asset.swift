import Foundation

protocol Asset {
	init(content: String)
	init(url: URL)
	func getHtml() -> String
}
