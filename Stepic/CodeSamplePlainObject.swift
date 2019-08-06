import Foundation

struct CodeSamplePlainObject {
    let input: String
    let output: String
}

extension CodeSamplePlainObject {
    init(codeSample: CodeSample) {
        self.input = codeSample.input
        self.output = codeSample.output
    }
}
