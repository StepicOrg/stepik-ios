import Foundation

protocol StepQuizReviewViewProtocol: AnyObject {
    var delegate: StepQuizReviewViewDelegate? { get set }

    func showLoading()
    func hideLoading()

    func configure(viewModel: StepQuizReviewViewModel)
}

protocol StepQuizReviewViewDelegate: AnyObject {
    func stepQuizReviewViewView(
        _ view: StepQuizReviewViewProtocol,
        didClickButtonWith uniqueIdentifier: UniqueIdentifierType?
    )
}
