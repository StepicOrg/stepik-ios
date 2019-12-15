import Foundation
import PromiseKit

protocol StepSourcesNetworkServiceProtocol: AnyObject {
    func fetch(ids: [StepSource.IdType], page: Int) -> Promise<([StepSource], Meta)>
    func update(stepSource: StepSource) -> Promise<StepSource>
}

extension StepSourcesNetworkServiceProtocol {
    func fetch(ids: [StepSource.IdType]) -> Promise<([StepSource], Meta)> {
        return self.fetch(ids: ids, page: 1)
    }
}

final class StepSourcesNetworkService: StepSourcesNetworkServiceProtocol {
    private let stepSourcesAPI: StepSourcesAPI

    init(stepSourcesAPI: StepSourcesAPI) {
        self.stepSourcesAPI = stepSourcesAPI
    }

    func fetch(ids: [StepSource.IdType], page: Int) -> Promise<([StepSource], Meta)> {
        if ids.isEmpty {
            return .value(([], Meta.oneAndOnlyPage))
        }

        return self.stepSourcesAPI.retrieve(ids: ids, page: page)
    }

    func update(stepSource: StepSource) -> Promise<StepSource> {
        return self.stepSourcesAPI.update(stepSource)
    }
}
