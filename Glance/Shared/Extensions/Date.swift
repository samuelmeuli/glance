import Foundation

extension Date {
	/// Converts the `Date` to a `yyyy-MM-dd` string
	func toDateString() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter.string(from: self)
	}
}
