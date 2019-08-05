import Foundation

struct StepOptionsPlainObject {
    let executionTimeLimit: Double
    let executionMemoryLimit: Double

    let limits: [CodeLimitPlainObject]
    let templates: [CodeTemplatePlainObject]
    let samples: [CodeSamplePlainObject]
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
