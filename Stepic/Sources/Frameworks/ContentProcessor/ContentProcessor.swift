import Foundation

protocol ContentProcessorProtocol {
    init(content: String, rules: [ContentProcessingRule], injections: [ContentProcessingInjection])

    func processContent() -> String
}

final class ContentProcessor: ContentProcessorProtocol {
    private let content: String
    private let rules: [ContentProcessingRule]
    private let injections: [ContentProcessingInjection]

    init(content: String, rules: [ContentProcessingRule] = [], injections: [ContentProcessingInjection] = []) {
        self.content = content
        self.rules = rules
        self.injections = injections
    }

    func processContent() -> String {
        var content = self.content

        for rule in self.rules {
            content = rule.process(content: content)
        }

        let injectionsToInject = self.injections.filter { $0.shouldInject(to: content) }
        let headInjections = injectionsToInject.map { $0.headScript }.joined(separator: "\n")
        let bodyHeadInjections = injectionsToInject.map { $0.bodyHeadScript }.joined(separator: "\n")
        let bodyTailInjections = injectionsToInject.map { $0.bodyTailScript }.joined(separator: "\n")

        return """
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
    }
}
