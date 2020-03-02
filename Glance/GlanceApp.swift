import Cocoa

// Source: https://stackoverflow.com/questions/40008141/nsapplicationdelegate-not-working-without-storyboard
class GlanceApp: NSApplication {
	// swiftlint:disable weak_delegate
	let strongDelegate = AppDelegate()

	override init() {
		super.init()
		delegate = strongDelegate
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
