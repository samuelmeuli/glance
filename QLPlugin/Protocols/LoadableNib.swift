import Cocoa

protocol LoadableNib {
	var contentView: NSView! { get }
}

/// Protocol for loading a custom `NSView` from Interface Builder
///
/// Source: https://stackoverflow.com/a/51350799/6767508
extension LoadableNib where Self: NSView {
	func loadViewFromNib(nibName: String) {
		let bundle = Bundle(for: type(of: self))
		let nib = NSNib(nibNamed: nibName, bundle: bundle)!
		_ = nib.instantiate(withOwner: self, topLevelObjects: nil)

		let contentConstraints = contentView.constraints
		contentView.subviews.forEach { addSubview($0) }

		for constraint in contentConstraints {
			let firstItem = (constraint.firstItem as? NSView == contentView)
				? self
				: constraint.firstItem
			let secondItem = (constraint.secondItem as? NSView == contentView)
				? self
				: constraint.secondItem
			addConstraint(
				NSLayoutConstraint(
					item: firstItem as Any,
					attribute: constraint.firstAttribute,
					relatedBy: constraint.relation,
					toItem: secondItem,
					attribute: constraint.secondAttribute,
					multiplier: constraint.multiplier,
					constant: constraint.constant
				)
			)
		}
	}
}
