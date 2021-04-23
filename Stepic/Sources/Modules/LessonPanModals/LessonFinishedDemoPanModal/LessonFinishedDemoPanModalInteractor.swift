import Foundation
import PromiseKit

protocol LessonFinishedDemoPanModalInteractorProtocol {
    func doModalLoad(request: LessonFinishedDemoPanModal.ModalLoad.Request)
    func doModalMainAction(request: LessonFinishedDemoPanModal.MainModalAction.Request)
}

final class LessonFinishedDemoPanModalInteractor: LessonFinishedDemoPanModalInteractorProtocol {
    weak var moduleOutput: LessonFinishedDemoPanModalOutputProtocol?

    private let presenter: LessonFinishedDemoPanModalPresenterProtocol
    private let provider: LessonFinishedDemoPanModalProviderProtocol

    private let sectionID: Section.IdType

    init(
        presenter: LessonFinishedDemoPanModalPresenterProtocol,
        provider: LessonFinishedDemoPanModalProviderProtocol,
        sectionID: Section.IdType
    ) {
        self.presenter = presenter
        self.provider = provider
        self.sectionID = sectionID
    }

    func doModalLoad(request: LessonFinishedDemoPanModal.ModalLoad.Request) {
        self.provider
            .fetchSection(id: self.sectionID)
            .compactMap { $0 }
            .then { section -> Promise<(Section, Course)> in
                if let course = section.course {
                    return .value((section, course))
                } else {
                    return self.provider
                        .fetchCourse(id: section.courseId)
                        .compactMap { $0 }
                        .then { course -> Promise<(Section, Course)> in
                            section.course = course
                            CoreDataHelper.shared.save()

                            return .value((section, course))
                        }
                }
            }
            .done { section, course in
                self.presenter.presentModal(response: .init(course: course, section: section))
            }
            .catch { error in
                print("LessonFinishedDemoPanModalInteractor :: failed load data with error = \(error)")
            }
    }

    func doModalMainAction(request: LessonFinishedDemoPanModal.MainModalAction.Request) {
        self.moduleOutput?.handleLessonFinishedDemoPanModalMainAction()
    }
}
