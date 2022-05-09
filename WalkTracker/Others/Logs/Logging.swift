import Foundation

func log(_ messages: String...) {
    if Environment.isLoggingEnabled {
        messages.forEach {
            print($0)
        }
    }
}
