import Foundation
import PromiseKit

extension WidgetContentFileManagerProtocol {
    func writeUserCourses(_ courses: [WidgetUserCourse]) -> Promise<Void> {
        Promise { seal in
            do {
                try self.writeUserCourses(courses)
                seal.fulfill(())
            } catch {
                seal.reject(error)
            }
        }
    }

    func readUserCourses() -> Guarantee<[WidgetUserCourse]> {
        Guarantee { seal in
            let courses = self.readUserCourses()
            seal(courses)
        }
    }
}
