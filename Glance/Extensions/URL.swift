import Cocoa
import Foundation

extension URL {
	func open() {
		NSWorkspace.shared.open(self)
	}
}
