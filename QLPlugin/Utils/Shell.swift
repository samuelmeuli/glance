import Foundation

class Shell {
	/// Executes the provided shell command, then parses and returns its status and output
	static func run(url: URL, arguments: [String] = []) -> (
		status: Int32,
		stdout: String?,
		stderr: String?
	) {
		let task = Process()
		task.executableURL = url
		task.arguments = arguments

		let outPipe = Pipe()
		let errPipe = Pipe()
		task.standardOutput = outPipe
		task.standardError = errPipe

		do {
			try task.run()
		} catch {
			return (status: -1, stdout: nil, stderr: error.localizedDescription)
		}

		// Convert stdout and stderr to strings
		let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
		let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
		let outStr = String(data: outData, encoding: .utf8)
		let errStr = String(data: errData, encoding: .utf8)

		task.waitUntilExit()

		return (status: task.terminationStatus, stdout: outStr, stderr: errStr)
	}
}
