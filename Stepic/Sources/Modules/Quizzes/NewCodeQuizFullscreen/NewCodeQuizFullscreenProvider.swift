import Foundation
import PromiseKit

protocol NewCodeQuizFullscreenProviderProtocol: AnyObject {
    func fetchCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<CodeTemplate?>
    func fetchUserCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<CodeTemplate?>
    func fetchUserOrCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<CodeTemplate?>

    func deleteUserCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<Void>
}

final class NewCodeQuizFullscreenProvider: NewCodeQuizFullscreenProviderProtocol {
    private let stepOptionsPersistenceService: StepOptionsPersistenceServiceProtocol

    init(
        stepOptionsPersistenceService: StepOptionsPersistenceServiceProtocol
    ) {
        self.stepOptionsPersistenceService = stepOptionsPersistenceService
    }

    func fetchCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<CodeTemplate?> {
        return self.stepOptionsPersistenceService.fetch(by: stepID).then { stepOptions -> Promise<CodeTemplate?> in
            if let stepOptions = stepOptions {
                return .value(stepOptions.template(language: language, userGenerated: false))
            } else {
                return .value(nil)
            }
        }
    }

    func fetchUserCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<CodeTemplate?> {
        return self.stepOptionsPersistenceService.fetch(by: stepID).then { stepOptions -> Promise<CodeTemplate?> in
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

    func deleteUserCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<Void> {
        return self.stepOptionsPersistenceService.fetch(by: stepID).done { stepOptions in
            guard let userTemplate = stepOptions?.template(language: language, userGenerated: true) else {
                return
            }

            CoreDataHelper.instance.deleteFromStore(userTemplate)
            CoreDataHelper.instance.save()
        }
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case fetchFailed
    }
}
