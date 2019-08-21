import UIKit

protocol NewMatchingQuizPresenterProtocol {
}

final class NewMatchingQuizPresenter: NewMatchingQuizPresenterProtocol {
    weak var viewController: NewMatchingQuizViewControllerProtocol?

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
