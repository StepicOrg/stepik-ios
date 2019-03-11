import UIKit

protocol TagsPresenterProtocol {
    func presentTags(response: Tags.TagsLoad.Response)
}

final class TagsPresenter: TagsPresenterProtocol {
    weak var viewController: TagsViewControllerProtocol?

    func presentTags(response: Tags.TagsLoad.Response) {
        let state: Tags.ViewControllerState = {
            switch response.result {
            case .success(let tags):
                var viewModels: [TagViewModel] = []
                for (uid, tag) in tags {
                    viewModels.append(
                        TagViewModel(uniqueIdentifier: uid, title: tag.title)
                    )
                }
                return Tags.ViewControllerState.result(
                    data: viewModels
                )
            case .failure:
                return Tags.ViewControllerState.emptyResult
            }
        }()

        let viewModel = Tags.TagsLoad.ViewModel(state: state)

        self.viewController?.displayTags(viewModel: viewModel)
    }
}
