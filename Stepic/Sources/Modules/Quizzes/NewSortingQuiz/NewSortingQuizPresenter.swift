import UIKit

protocol NewSortingQuizPresenterProtocol {
    func presentReply(response: NewSortingQuiz.ReplyLoad.Response)
}

final class NewSortingQuizPresenter: NewSortingQuizPresenterProtocol {
    weak var viewController: NewSortingQuizViewControllerProtocol?

    func presentReply(response: NewSortingQuiz.ReplyLoad.Response) {
        let viewModel = NewSortingQuizViewModel(
            options: response.options.map { self.processOption($0) },
            isEnabled: response.status != .correct
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }

    private func processOption(_ option: String) -> String {
        let text = option.addingHTMLEntities()

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
