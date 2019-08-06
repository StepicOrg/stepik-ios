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
