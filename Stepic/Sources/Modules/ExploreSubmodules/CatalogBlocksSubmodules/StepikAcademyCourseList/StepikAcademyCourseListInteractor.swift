import Foundation
import PromiseKit

protocol StepikAcademyCourseListInteractorProtocol {
    func doCourseListLoad(request: StepikAcademyCourseList.CourseListLoad.Request)
    func doSpecializationPresentation(request: StepikAcademyCourseList.SpecializationPresentation.Request)
}

final class StepikAcademyCourseListInteractor: StepikAcademyCourseListInteractorProtocol {
    weak var moduleOutput: StepikAcademyCourseListOutputProtocol?

    private let presenter: StepikAcademyCourseListPresenterProtocol
    private let provider: StepikAcademyCourseListProviderProtocol

    private let catalogBlockID: CatalogBlock.IdType
    private var currentContentItems = [SpecializationsCatalogBlockContentItem]()

    init(
        catalogBlockID: CatalogBlock.IdType,
        presenter: StepikAcademyCourseListPresenterProtocol,
        provider: StepikAcademyCourseListProviderProtocol
    ) {
        self.catalogBlockID = catalogBlockID
        self.presenter = presenter
        self.provider = provider
    }

    func doCourseListLoad(request: StepikAcademyCourseList.CourseListLoad.Request) {
        self.fetchCatalogBlock(id: self.catalogBlockID).done { catalogBlockOrNil in
            guard let catalogBlock = catalogBlockOrNil,
                  let contentItems = catalogBlock.content as? [SpecializationsCatalogBlockContentItem] else {
                throw Error.fetchFailed
            }

            guard catalogBlock.kind == .specializations else {
                throw Error.invalidKind
            }

            guard catalogBlock.appearance == .specializationsStepikAcademy else {
                throw Error.invalidAppearance
            }

            self.currentContentItems = contentItems

            self.presenter.presentCourseList(response: .init(result: .success(contentItems)))
        }.catch { error in
            print("StepikAcademyCourseListInteractor :: failed fetch catalog block with error = \(error)")
            self.presenter.presentCourseList(response: .init(result: .failure(error)))
        }
    }

    func doSpecializationPresentation(request: StepikAcademyCourseList.SpecializationPresentation.Request) {
        guard let targetItem = self.currentContentItems.first(where: { "\($0.id)" == request.uniqueIdentifier }),
              let detailsURL = URL(string: targetItem.detailsURLString) else {
            return
        }

        self.moduleOutput?.presentStepikAcademySpecialization(url: detailsURL)
    }

    // MARK: Private API

    private func fetchCatalogBlock(id: CatalogBlock.IdType) -> Promise<CatalogBlock?> {
        self.provider.fetchCachedCatalogBlock(id: id).then { cachedCatalogBlockOrNil -> Promise<CatalogBlock?> in
            if let cachedCatalogBlock = cachedCatalogBlockOrNil {
                return .value(cachedCatalogBlock)
            }
            return self.provider.fetchRemoteCatalogBlock(id: id)
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case invalidKind
        case invalidAppearance
    }
}
