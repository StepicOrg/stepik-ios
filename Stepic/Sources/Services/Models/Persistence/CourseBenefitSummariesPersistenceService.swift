import CoreData
import PromiseKit

protocol CourseBenefitSummariesPersistenceServiceProtocol: AnyObject {
    func fetch(id: CourseBenefitSummary.IdType) -> Guarantee<CourseBenefitSummary?>
    func fetchAll() -> Guarantee<[CourseBenefitSummary]>

    func deleteAll() -> Promise<Void>
}

final class CourseBenefitSummariesPersistenceService: BasePersistenceService<CourseBenefitSummary>,
                                                      CourseBenefitSummariesPersistenceServiceProtocol {}
