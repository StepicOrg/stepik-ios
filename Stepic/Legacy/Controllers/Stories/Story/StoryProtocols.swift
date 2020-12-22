import Foundation

protocol StoryURLNavigationDelegate: AnyObject {
    func open(url: URL)
}

protocol UIStoryPartViewProtocol {
    var completion: (() -> Void)? { get set }
    var onDidChangeReaction: ((StoryReaction) -> Void)? { get set }

    func startLoad()
    func setReaction(_ reaction: StoryReaction?)
}

enum StoryReaction: String {
    case like
    case dislike
}
