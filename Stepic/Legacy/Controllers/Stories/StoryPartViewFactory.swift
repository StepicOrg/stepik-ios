import UIKit

final class StoryPartViewFactory {
    weak var urlNavigationDelegate: StoryURLNavigationDelegate?

    init(urlNavigationDelegate: StoryURLNavigationDelegate?) {
        self.urlNavigationDelegate = urlNavigationDelegate
    }

    func makeView(storyPart: StoryPart) -> (UIView & UIStoryPartViewProtocol)? {
        guard let type = storyPart.type else {
            return nil
        }

        switch type {
        case .text:
            guard let textStoryPart = storyPart as? TextStoryPart else {
                return nil
            }

            let textStoryView: TextStoryView = .fromNib()
            textStoryView.configure(storyPart: textStoryPart, urlNavigationDelegate: self.urlNavigationDelegate)

            return textStoryView
        case .feedback:
            guard let feedbackStoryPart = storyPart as? FeedbackStoryPart else {
                return nil
            }

            let feedbackStoryView = FeedbackStoryView()
            feedbackStoryView.configure(storyPart: feedbackStoryPart)

            return feedbackStoryView
        }
    }
}
