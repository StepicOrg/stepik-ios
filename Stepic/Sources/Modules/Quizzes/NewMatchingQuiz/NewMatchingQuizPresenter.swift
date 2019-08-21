import UIKit

protocol NewMatchingQuizPresenterProtocol {
    func presentReply(response: NewMatchingQuiz.ReplyLoad.Response)
}

final class NewMatchingQuizPresenter: NewMatchingQuizPresenterProtocol {
    weak var viewController: NewMatchingQuizViewControllerProtocol?

    func presentReply(response: NewMatchingQuiz.ReplyLoad.Response) {
        let items: [NewMatchingQuiz.MatchItem] = response.items.map { item in
            .init(
                title: .init(id: item.title.id, text: self.processText(item.title.text)),
                option: .init(id: item.option.id, text: self.processText(item.option.text))
            )
        }

        let viewModel = NewMatchingQuizViewModel(
            items: items,
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
