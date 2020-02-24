import Foundation

protocol CodeQuizFullscreenRunCodeInputProtocol: AnyObject {
    func update(code: String)
    func update(samples: [CodeSamplePlainObject])
}
