import Foundation
import PromiseKit

protocol CodeLanguageSuggestionsServiceProtocol: class {
    func suggest(stepID: Step.IdType) -> Guarantee<CodeLanguage?>
    func update(language: CodeLanguage, stepID: Step.IdType) -> Promise<Void>
}

final class CodeLanguageSuggestionsService: CodeLanguageSuggestionsServiceProtocol {
    private let stepsPersistenceService: StepsPersistenceServiceProtocol

    init(stepsPersistenceService: StepsPersistenceServiceProtocol) {
        self.stepsPersistenceService = stepsPersistenceService
    }

    func suggest(stepID: Step.IdType) -> Guarantee<CodeLanguage?> {
        return Guarantee { seal in
            self.stepsPersistenceService.fetch(ids: [stepID]).done { steps in
                guard let step = steps.first else {
                    return seal(nil)
                }

                guard let course = LastStepGlobalContext.context.course else {
                    return seal(self.getMostPopularLanguage(step: step))
                }

                if let lastCodeLanguage = course.lastCodeLanguage,
                   let language = lastCodeLanguage.language {
                    seal(language)
                } else {
                    seal(self.getMostPopularLanguage(step: step))
                }
            }.catch { _ in
                seal(nil)
            }
        }
    }

    func update(language: CodeLanguage, stepID: Step.IdType) -> Promise<Void> {
        return Promise { seal in
            guard let course = LastStepGlobalContext.context.course else {
                return seal.reject(Error.fetchFailed)
            }

            if course.lastCodeLanguage != nil {
                course.lastCodeLanguage?.languageString = language.rawValue
            } else {
                course.lastCodeLanguage = LastCodeLanguage(language: language)
            }

            CoreDataHelper.instance.save()
            seal.fulfill(())
        }
    }

    // MARK: - Private API

    private func getMostPopularLanguage(step: Step) -> CodeLanguage? {
        guard let options = step.options else {
            return nil
        }

        return options.languages.randomElement()
    }

    // MARK: - Inner Types

    enum Error: Swift.Error {
        case fetchFailed
    }
}
