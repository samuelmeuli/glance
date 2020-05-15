import Cocoa

class AppIcon: NSImageView {
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		image = NSApplication.shared.applicationIconImage
	}
}
