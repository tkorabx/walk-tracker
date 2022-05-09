import Foundation

// Dummy implementation of caching for images

typealias PhotoDataCache = NSCache<NSString, NSData>

extension PhotoDataCache {
    static let photoDataCache = NSCache<NSString, NSData>()
}
