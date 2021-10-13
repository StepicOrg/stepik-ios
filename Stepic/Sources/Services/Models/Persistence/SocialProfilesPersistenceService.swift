import CoreData
import PromiseKit

protocol SocialProfilesPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [SocialProfile.IdType]) -> Promise<[SocialProfile]>
    func deleteAll() -> Promise<Void>
}

final class SocialProfilesPersistenceService: BasePersistenceService<SocialProfile>,
                                              SocialProfilesPersistenceServiceProtocol {
    func fetch(ids: [SocialProfile.IdType]) -> Promise<[SocialProfile]> {
        firstly { () -> Guarantee<[SocialProfile]> in
            self.fetch(ids: ids)
        }
    }
}
