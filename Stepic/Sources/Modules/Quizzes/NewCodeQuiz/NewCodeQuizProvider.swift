import Foundation
import PromiseKit

protocol NewCodeQuizProviderProtocol {
    func fetchStepOptions(by stepID: Step.IdType) -> Promise<StepOptions?>

    func fetchCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<CodeTemplate?>
    func fetchUserCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<CodeTemplate?>
    func fetchUserOrCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<CodeTemplate?>

    func updateUserCodeTemplate(stepID: Step.IdType, language: CodeLanguage, code: String) -> Promise<Void>
}

final class NewCodeQuizProvider: NewCodeQuizProviderProtocol {
    private let stepOptionsPersistenceService: StepOptionsPersistenceServiceProtocol

    init(
        stepOptionsPersistenceService: StepOptionsPersistenceServiceProtocol
    ) {
        self.stepOptionsPersistenceService = stepOptionsPersistenceService
    }

    func fetchStepOptions(by stepID: Step.IdType) -> Promise<StepOptions?> {
        return self.stepOptionsPersistenceService.fetch(by: stepID)
    }

    func fetchCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<CodeTemplate?> {
        return self.fetchStepOptions(by: stepID).then { stepOptions -> Promise<CodeTemplate?> in
            if let stepOptions = stepOptions {
                return .value(stepOptions.template(language: language, userGenerated: false))
            } else {
                return .value(nil)
            }
        }
    }

    func fetchUserCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<CodeTemplate?> {
        return self.fetchStepOptions(by: stepID).then { stepOptions -> Promise<CodeTemplate?> in
            if let stepOptions = stepOptions {
                return .value(stepOptions.template(language: language, userGenerated: true))
            } else {
                return .value(nil)
            }
        }
    }

    func fetchUserOrCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<CodeTemplate?> {
        return Promise { seal in
            when(
                fulfilled: self.fetchUserCodeTemplate(by: stepID, language: language),
                self.fetchCodeTemplate(by: stepID, language: language)
            ).then { userTemplate, template -> Promise<CodeTemplate?> in
                if let userTemplate = userTemplate {
                    return .value(userTemplate)
                }

                return .value(template)
            }.done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func updateUserCodeTemplate(stepID: Step.IdType, language: CodeLanguage, code: String) -> Promise<Void> {
        return Promise { seal in
            when(
                fulfilled: self.fetchStepOptions(by: stepID),
                self.fetchUserCodeTemplate(by: stepID, language: language)
            ).done { stepOptions, userTemplate in
                guard let stepOptions = stepOptions else {
                    return
                }

                if let userTemplate = userTemplate {
                    userTemplate.templateString = code
                } else {
                    let newUserTemplate = CodeTemplate(language: language, template: code)
                    newUserTemplate.isUserGenerated = true
                    stepOptions.templates += [newUserTemplate]
                }

                CoreDataHelper.instance.save()
            }.catch { _ in
                seal.reject(Error.templateUpdateFailed)
            }
        }
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case fetchFailed
        case templateUpdateFailed
    }
}
