import UIKit

protocol NewSortingQuizPresenterProtocol {
    func presentReply(response: NewSortingQuiz.ReplyLoad.Response)
}

final class NewSortingQuizPresenter: NewSortingQuizPresenterProtocol {
    weak var viewController: NewSortingQuizViewControllerProtocol?

    func presentReply(response: NewSortingQuiz.ReplyLoad.Response) {
        let viewModel = NewSortingQuizViewModel(
            title: NSLocalizedString("SortingQuizTitle", comment: ""),
            options: response.options.map { .init(id: $0.id, text: self.processText($0.text)) },
            isEnabled: response.status == nil
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }

    private func processText(_ text: String) -> String {
        let text = text.addingHTMLEntities()

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
