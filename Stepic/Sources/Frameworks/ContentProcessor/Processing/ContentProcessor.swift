import Foundation

protocol ContentProcessorProtocol {
    init(rules: [ContentProcessingRule], injections: [ContentProcessingInjection])

    func processContent(_ content: String) -> ProcessedContent
}

final class ContentProcessor: ContentProcessorProtocol {
    static let defaultInjections: [ContentProcessingInjection] = [
        CustomAudioControlInjection(),
        ClickableImagesInjection(),
        KotlinRunnableSamplesInjection(),
        MathJaxInjection(),
        CommonStylesInjection(),
        MetaViewportInjection(),
        HightlightJSInjection(),
        WebkitImagesCalloutDisableInjection(),
        WebScriptInjection()
    ]

    static let defaultRules: [ContentProcessingRule] = [
        FixRelativeProtocolURLsRule(),
        AddStepikSiteForRelativeURLsRule(extractorType: HTMLExtractor.self),
        RemoveImageFixedHeightRule(extractorType: HTMLExtractor.self),
        AlwaysOpenedDetailsDisclosureBoxRule()
    ]

    private let rules: [ContentProcessingRule]
    private let injections: [ContentProcessingInjection]

    init(
        rules: [ContentProcessingRule] = ContentProcessor.defaultRules,
        injections: [ContentProcessingInjection] = ContentProcessor.defaultInjections
    ) {
        self.rules = rules
        self.injections = injections
    }

    func processContent(_ content: String) -> ProcessedContent {
        var content = content

        for rule in self.rules {
            content = rule.process(content: content)
        }

        let primaryInjections = self.injections.filter {
            (
                $0 is KotlinRunnableSamplesInjection ||
                $0 is MathJaxInjection ||
                $0 is HightlightJSInjection ||
                $0 is WebScriptInjection
            ) && $0.shouldInject(to: content)
        }

        if primaryInjections.isEmpty {
            return .text(content.trimmed())
        } else {
            let injectionsToInject = self.injections.filter { $0.shouldInject(to: content) }
            let headInjections = injectionsToInject.map { $0.headScript }.joined(separator: "\n")
            let bodyHeadInjections = injectionsToInject.map { $0.bodyHeadScript }.joined(separator: "\n")
            let bodyTailInjections = injectionsToInject.map { $0.bodyTailScript }.joined(separator: "\n")

            let text = """
            <html>
            <head>
                \(headInjections)
            </head>
            <body>
                \(bodyHeadInjections)
                \(content)
                \(bodyTailInjections)
            </body>
            </html>
            """

            return .html(text.trimmed())
        }
    }
}
