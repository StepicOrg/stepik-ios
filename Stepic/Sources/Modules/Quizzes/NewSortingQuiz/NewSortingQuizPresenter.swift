import UIKit

protocol NewSortingQuizPresenterProtocol {
    func presentReply(response: NewSortingQuiz.ReplyLoad.Response)
}

final class NewSortingQuizPresenter: NewSortingQuizPresenterProtocol {
    weak var viewController: NewSortingQuizViewControllerProtocol?

    func presentReply(response: NewSortingQuiz.ReplyLoad.Response) {
        let state: NewSortingQuizViewModel.State? = {
            guard let status = response.status else {
                return nil
            }

            switch status {
            case .correct:
                return .correct
            case .wrong:
                return .wrong
            case .evaluation:
                return .evaluation
            }
        }()

        let viewModel = NewSortingQuizViewModel(
            title: response.isQuizTitleVisible ? NSLocalizedString("SortingQuizTitle", comment: "") : nil,
            options: response.options.map { .init(id: $0.id, text: self.processText($0.text)) },
            finalState: state
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }

    private func processText(_ text: String) -> String {
        let processor = ContentProcessor(
            content: text,
            rules: [
                FixRelativeProtocolURLsRule(),
                AddStepikSiteForRelativeURLsRule(extractorType: HTMLExtractor.self)
            ],
            injections: [
                MathJaxInjection(),
                CommonStylesInjection(),
                MetaViewportInjection(),
                WebkitImagesCalloutDisableInjection()
            ]
        )

        return processor.processContent()
    }
}
