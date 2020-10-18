import Foundation

struct VideoURLPlainObject: Equatable {
    let quality: String
    let url: String
}

extension VideoURLPlainObject {
    init(videoURL: VideoURL) {
        self.quality = videoURL.quality
        self.url = videoURL.url
    }
}
