import Foundation

// MARK: - Quick and simple implementation of Environment using xcconfig files

enum Environment {

    private static let configurationProperties = Bundle.main.infoDictionary ?? [:]

    static var urlScheme: String {
        value(for: "APPLICATION_URL_SCHEME")
    }

    static var urlHost: String {
        value(for: "APPLICATION_URL_HOST")
    }

    static var isLoggingEnabled: Bool {
        value(for: "APPLICATION_LOGGING_ENABLED") == "1"
    }

    // Normally it would be received from a server and stored in Keychain because of sensitivity.
    // In case of this sample app, I have stored it in xcconfig to make it faster
    static var flickrApiKey: String {
        value(for: "APPLICATION_FLICKR_API_KEY")
    }

    // Indicates whether application is disconnected from all remote services and uses local stubs as responses
    static var isAppOffline: Bool {
        urlScheme == "mock"
    }

    private static func value(for key: String) -> String {
        guard let value = configurationProperties[key] as? String else {
            fatalError("Missing required configuration property")
        }
        return value
    }
}
