import Foundation

struct BlockPlainObject: Equatable {
    let name: String
    let type: BlockType?
    let text: String?
    let video: VideoPlainObject?
    let imageSourceURLs: [URL]
}

extension BlockPlainObject {
    init(block: Block) {
        self.name = block.name
        self.type = block.type
        self.text = block.text

        if let video = block.video {
            self.video = VideoPlainObject(video: video)
        } else {
            self.video = nil
        }

        self.imageSourceURLs = block.imageSourceURLs
    }
}
