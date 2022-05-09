import Foundation

// Wrapper to simplify decoding and passing binary data
struct RawResource: Decodable {
    let data: Data
}
