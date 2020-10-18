import Foundation

struct VideoPlainObject: Equatable {
    let id: Int
    let thumbnailURL: String
    let status: String
    let urls: [VideoURLPlainObject]
}

extension VideoPlainObject {
    init(video: Video) {
        self.id = video.id
        self.thumbnailURL = video.thumbnailURL
        self.status = video.status
        self.urls = video.urls.map { VideoURLPlainObject(videoURL: $0) }
    }
}
