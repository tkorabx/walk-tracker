import Foundation

struct GeoSearchedPhotos: Decodable {

    let photos: Photos

    struct Photos: Decodable {

        let photo: [Photo]

        struct Photo: Decodable {
            let id: String
        }
    }
}
