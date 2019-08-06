import Foundation

struct StepOptionsPlainObject {
    let executionTimeLimit: Double
    let executionMemoryLimit: Double

    let limits: [CodeLimitPlainObject]
    let templates: [CodeTemplatePlainObject]
    let samples: [CodeSamplePlainObject]

    var languages: [CodeLanguage] {
        return self.limits.compactMap { CodeLanguage(rawValue: $0.language) }
    }

    func getLimit(for language: CodeLanguage) -> CodeLimitPlainObject? {
        return self.limits.first(where: { $0.language == language.rawValue })
    }

    func getTemplate(for language: CodeLanguage) -> CodeTemplatePlainObject? {
        return self.getTemplate(for: language, isUserGenerated: false)
    }

    func getUserTemplate(for language: CodeLanguage) -> CodeTemplatePlainObject? {
        return self.getTemplate(for: language, isUserGenerated: true)
    }

    private func getTemplate(for language: CodeLanguage, isUserGenerated: Bool) -> CodeTemplatePlainObject? {
        return self.templates
            .first(where: { $0.language == language.rawValue && $0.isUserGenerated == isUserGenerated })
    }
}

extension StepOptionsPlainObject {
    init(stepOptions: StepOptions) {
        self.executionTimeLimit = stepOptions.executionTimeLimit
        self.executionMemoryLimit = stepOptions.executionMemoryLimit

        self.limits = stepOptions.limits.map { CodeLimitPlainObject(codeLimit: $0) }
        self.templates = stepOptions.templates.map { CodeTemplatePlainObject(codeTemplate: $0) }
        self.samples = stepOptions.samples.map { CodeSamplePlainObject(codeSample: $0) }
    }
}
