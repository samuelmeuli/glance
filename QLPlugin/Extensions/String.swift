import Foundation

extension String {
	// Returns the string with the first letter capitalized.
	var firstCapitalized: String { prefix(1).capitalized + dropFirst() }

	/// Returns all matches and capturing groups for the provided regular expression applied to the
	/// string
	///
	/// Source: https://stackoverflow.com/a/40040472/6767508
	func matchRegex(regex: String) -> [[String]] {
		guard let regex = try? NSRegularExpression(pattern: regex, options: [
			.anchorsMatchLines, // Allow `^` and `$` to match the start and end of lines
		]) else {
			return []
		}
		let nsString = self as NSString
		let results = regex.matches(
			in: self,
			options: [],
			range: NSRange(location: 0, length: nsString.length)
		)
		return results.map { result in
			(0 ..< result.numberOfRanges).map {
				result.range(at: $0).location != NSNotFound
					? nsString.substring(with: result.range(at: $0))
					: ""
			}
		}
	}
}
