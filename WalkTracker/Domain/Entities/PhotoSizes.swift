import Foundation

struct PhotoSizes: Decodable {

    let sizes: Sizes

    struct Sizes: Decodable {

        let size: [Size]

        struct Size: Decodable {
            let label: String
            let source: URL
            let width: Double
        }
    }
}
