import Foundation
import PromiseKit

protocol SectionsNetworkServiceProtocol: class {
    func fetch(ids: [Section.IdType]) -> Promise<[Section]>
    func fetch(id: Section.IdType) -> Promise<Section?>
}

final class SectionsNetworkService: SectionsNetworkServiceProtocol {
    private let sectionsAPI: SectionsAPI

    init(sectionsAPI: SectionsAPI) {
        self.sectionsAPI = sectionsAPI
    }

    func fetch(ids: [Section.IdType]) -> Promise<[Section]> {
        return Promise { seal in
            self.sectionsAPI.retrieve(ids: ids).done { sections in
                let sections = sections.reordered(order: ids, transform: { $0.id })
                seal.fulfill(sections)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(id: Section.IdType) -> Promise<Section?> {
        return self.fetch(ids: [id]).then { result -> Promise<Section?> in
            Promise.value(result.first)
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
