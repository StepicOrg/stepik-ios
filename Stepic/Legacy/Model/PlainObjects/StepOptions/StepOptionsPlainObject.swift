import Foundation

struct StepOptionsPlainObject: Equatable {
    let executionTimeLimit: Double
    let executionMemoryLimit: Double
    let isRunUserCodeAllowed: Bool

    let limits: [CodeLimitPlainObject]
    let templates: [CodeTemplatePlainObject]
    let samples: [CodeSamplePlainObject]

    func getLanguages() -> [CodeLanguage] {
        self.limits.compactMap { CodeLanguage(rawValue: $0.language ?? "") }
    }

    func getLimit(for language: CodeLanguage) -> CodeLimitPlainObject? {
        self.limits.first(where: { $0.language == language.rawValue })
    }

    func getTemplate(for language: CodeLanguage) -> CodeTemplatePlainObject? {
        self.getTemplate(for: language, isUserGenerated: false)
    }

    func getUserTemplate(for language: CodeLanguage) -> CodeTemplatePlainObject? {
        self.getTemplate(for: language, isUserGenerated: true)
    }

    private func getTemplate(for language: CodeLanguage, isUserGenerated: Bool) -> CodeTemplatePlainObject? {
        self.templates.first(where: { $0.language == language.rawValue && $0.isUserGenerated == isUserGenerated })
    }
}

extension StepOptionsPlainObject {
    init(stepOptions: StepOptions) {
        self.executionTimeLimit = stepOptions.executionTimeLimit
        self.executionMemoryLimit = stepOptions.executionMemoryLimit
        self.isRunUserCodeAllowed = stepOptions.isRunUserCodeAllowed

        self.limits = stepOptions.limits.map { CodeLimitPlainObject(codeLimit: $0) }
        self.templates = stepOptions.templates.map { CodeTemplatePlainObject(codeTemplate: $0) }
        self.samples = stepOptions.samples.map { CodeSamplePlainObject(codeSample: $0) }
    }
}
