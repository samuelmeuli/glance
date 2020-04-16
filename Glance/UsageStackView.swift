import Cocoa

class UsageStackView: NSStackView {
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		configure()
	}

	func configure() {
		wantsLayer = true
		if #available(OSX 10.14, *) {
			self.layer?.backgroundColor = NSColor.alternatingContentBackgroundColors[0].cgColor
		} else {
			layer?.backgroundColor = NSColor.white.cgColor
		}
	}
}
