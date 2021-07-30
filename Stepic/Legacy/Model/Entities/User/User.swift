import CoreData
import SwiftyJSON

@objc
final class User: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = Int

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: false)]
    }

    /// Returns true if joinDate is less than in 5 minutes from now.
    var didJustRegister: Bool {
        if let joinDate = self.joinDate {
            return Date().timeIntervalSince(joinDate) < 5 * 60
        }
        return false
    }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.profile = json[JSONKey.profile.rawValue].intValue
        self.isPrivate = json[JSONKey.isPrivate.rawValue].boolValue
        self.isGuest = json[JSONKey.isGuest.rawValue].boolValue
        self.isActive = json[JSONKey.isActive.rawValue].boolValue
        self.isOrganization = json[JSONKey.isOrganization.rawValue].boolValue
        self.bio = json[JSONKey.shortBio.rawValue].stringValue
        self.details = json[JSONKey.details.rawValue].stringValue
        self.firstName = json[JSONKey.firstName.rawValue].stringValue
        self.lastName = json[JSONKey.lastName.rawValue].stringValue
        self.avatarURL = json[JSONKey.avatar.rawValue].stringValue
        self.cover = json[JSONKey.cover.rawValue].string
        self.knowledge = json[JSONKey.knowledge.rawValue].intValue
        self.knowledgeRank = json[JSONKey.knowledgeRank.rawValue].intValue
        self.reputation = json[JSONKey.reputation.rawValue].intValue
        self.reputationRank = json[JSONKey.reputationRank.rawValue].intValue
        self.joinDate = Parser.dateFromTimedateJSON(json[JSONKey.joinDate.rawValue])
        self.solvedStepsCount = json[JSONKey.solvedStepsCount.rawValue].intValue
        self.createdCoursesCount = json[JSONKey.createdCoursesCount.rawValue].intValue
        self.createdLessonsCount = json[JSONKey.createdLessonsCount.rawValue].intValue
        self.issuedCertificatesCount = json[JSONKey.issuedCertificatesCount.rawValue].intValue
        self.followersCount = json[JSONKey.followersCount.rawValue].intValue
        self.socialProfilesArray = json[JSONKey.socialProfiles.rawValue].arrayObject as? [Int] ?? []
    }

    @available(*, deprecated, message: "Legacy")
    static func fetchById(_ id: Int) -> [User]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        let predicate = NSPredicate(format: "managedId== %@", id as NSNumber)

        request.predicate = predicate

        do {
            let results = try CoreDataHelper.shared.context.fetch(request)
            return results as? [User]
        } catch {
            return nil
        }
    }

    @available(*, deprecated, message: "Legacy")
    static func removeAllExcept(_ user: User) {
        if let fetchedUsers = fetchById(user.id) {
            for fetchedUser in fetchedUsers {
                if fetchedUser != user {
                    CoreDataHelper.shared.deleteFromStore(fetchedUser, save: false)
                }
            }
            CoreDataHelper.shared.save()
        }
    }

    @available(*, deprecated, message: "Legacy")
    static func fetch(_ ids: [Int]) -> [User] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        let idPredicates = ids.map {
            NSPredicate(format: "managedId == %@", $0 as NSNumber)
        }
        request.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)
        do {
            guard let results = try CoreDataHelper.shared.context.fetch(request) as? [User] else {
                return []
            }
            return results
        } catch {
            return []
        }
    }

    enum JSONKey: String {
        case id
        case profile
        case isPrivate = "is_private"
        case isGuest = "is_guest"
        case isOrganization = "is_organization"
        case shortBio = "short_bio"
        case details
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
        case cover
        case joinDate = "join_date"
        case isActive = "is_active"
        case knowledge
        case knowledgeRank = "knowledge_rank"
        case reputation
        case reputationRank = "reputation_rank"
        case solvedStepsCount = "solved_steps_count"
        case createdCoursesCount = "created_courses_count"
        case createdLessonsCount = "created_lessons_count"
        case issuedCertificatesCount = "issued_certificates_count"
        case followersCount = "followers_count"
        case socialProfiles = "social_profiles"
    }
}

struct UserInfo {
    var id: Int
    var avatarURL: String
    var firstName: String
    var lastName: String

    init(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.avatarURL = json[JSONKey.avatar.rawValue].stringValue
        self.firstName = json[JSONKey.firstName.rawValue].stringValue
        self.lastName = json[JSONKey.lastName.rawValue].stringValue
    }

    enum JSONKey: String {
        case id
        case avatar
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
