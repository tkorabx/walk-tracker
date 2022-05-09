import Foundation

struct RequestBuilder {

    let path: String
    let queryItems: [URLQueryItem]

    init(path: String, queries: [String: String]) {
        self.path = path
        self.queryItems = queries.map(URLQueryItem.init)
    }

    func build() -> URLRequest {
        var components = URLComponents()

        components.scheme = Environment.urlScheme
        components.host = Environment.urlHost
        components.path = path
        components.queryItems = queryItems

        guard let url = components.url else {
            fatalError("Couldn't build URL from the input")
        }

        return URLRequest(url: url)
    }
}
