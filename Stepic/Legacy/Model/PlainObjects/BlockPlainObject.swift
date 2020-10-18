import Foundation

struct BlockPlainObject: Equatable {
    let name: String
    let text: String?
    let video: VideoPlainObject?
}

extension BlockPlainObject {
    init(block: Block) {
        self.name = block.name
        self.text = block.text

        if let video = block.video {
            self.video = VideoPlainObject(video: video)
        } else {
            self.video = nil
        }
    }
}
