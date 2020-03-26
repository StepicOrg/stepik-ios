import Foundation

struct CodeTemplatePlainObject {
    let language: String
    let template: String
    let isUserGenerated: Bool
}

extension CodeTemplatePlainObject {
    init(codeTemplate: CodeTemplate) {
        self.language = codeTemplate.languageString
        self.template = codeTemplate.templateString
        self.isUserGenerated = codeTemplate.isUserGenerated
    }
}
