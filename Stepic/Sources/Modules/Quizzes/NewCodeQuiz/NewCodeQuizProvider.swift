import Foundation
import PromiseKit

protocol NewCodeQuizProviderProtocol {
    func fetchStepOptions(by stepID: Step.IdType) -> Promise<StepOptions?>

    func fetchCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<CodeTemplate?>
    func fetchUserCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<CodeTemplate?>
    func fetchUserOrCodeTemplate(by stepID: Step.IdType, language: CodeLanguage) -> Promise<CodeTemplate?>

    func updateUserCodeTemplate(stepID: Step.IdType, language: CodeLanguage, code: String) -> Promise<Void>

    func fetchLessonTitle(by stepID: Step.IdType) -> Guarantee<String?>

    func fetchAutoSuggestedCodeLanguage(by stepID: Step.IdType) -> Guarantee<CodeLanguage?>
    func updateAutoSuggestedCodeLanguage(language: CodeLanguage, stepID: Step.IdType) -> Promise<Void>
}

final class NewCodeQuizProvider: NewCodeQuizProviderProtocol {
    private let stepsPersistenceService: StepsPersistenceServiceProtocol
    private let stepOptionsPersistenceService: StepOptionsPersistenceServiceProtocol
    private let lessonsPersistenceService: LessonsPersistenceServiceProtocol
    private let languageSuggestionsService: CodeLanguageSuggestionsServiceProtocol

    init(
        stepsPersistenceService: StepsPersistenceServiceProtocol,
        stepOptionsPersistenceService: StepOptionsPersistenceServiceProtocol,
        lessonsPersistenceService: LessonsPersistenceServiceProtocol,
        languageSuggestionsService: CodeLanguageSuggestionsServiceProtocol
    ) {
        self.stepsPersistenceService = stepsPersistenceService
        self.stepOptionsPersistenceService = stepOptionsPersistenceService
        self.lessonsPersistenceService = lessonsPersistenceService
        self.languageSuggestionsService = languageSuggestionsService
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

    func fetchLessonTitle(by stepID: Step.IdType) -> Guarantee<String?> {
        return Guarantee { seal in
            self.stepsPersistenceService.fetch(ids: [stepID]).then { steps -> Promise<String?> in
                if let step = steps.first {
                    if let lesson = step.lesson {
                        return .value(lesson.title)
                    }
                    return self.lessonsPersistenceService.fetch(ids: [step.lessonId]).firstValue.then {
                        lesson -> Promise<String?> in
                            .value(lesson.title)
                    }
                }
                return .value(nil)
            }.done { result in
                seal(result)
            }.catch { _ in
                seal(nil)
            }
        }
    }

    func fetchAutoSuggestedCodeLanguage(by stepID: Step.IdType) -> Guarantee<CodeLanguage?> {
        return self.languageSuggestionsService.suggest(stepID: stepID)
    }

    func updateAutoSuggestedCodeLanguage(language: CodeLanguage, stepID: Step.IdType) -> Promise<Void> {
        return self.languageSuggestionsService.update(language: language, stepID: stepID)
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case fetchFailed
        case templateUpdateFailed
    }
}
