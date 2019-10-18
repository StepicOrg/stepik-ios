import UIKit

protocol NewDiscussionsPresenterProtocol {
    func presentDiscussions(response: NewDiscussions.DiscussionsLoad.Response)
}

final class NewDiscussionsPresenter: NewDiscussionsPresenterProtocol {
    weak var viewController: NewDiscussionsViewControllerProtocol?

    func presentDiscussions(response: NewDiscussions.DiscussionsLoad.Response) {
        switch response.result {
        case .success(let result):
            assert(result.discussions.filter({ !$0.repliesIDs.isEmpty }).count == result.replies.keys.count)
            print(result)
        case .failure:
            break
        }
    }
}
