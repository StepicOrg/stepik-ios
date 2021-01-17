import Foundation

protocol WidgetContentFileManagerProtocol: AnyObject {
    func writeUserCourses(_ courses: [WidgetUserCourse]) throws
    func readUserCourses() -> [WidgetUserCourse]
}

final class WidgetContentFileManager: WidgetContentFileManagerProtocol {
    private static let fileName = "user-courses.json"

    private let containerURL: URL

    private var archiveURL: URL {
        self.containerURL.appendingPathComponent(Self.fileName)
    }

    init(containerURL: URL) {
        self.containerURL = containerURL
    }

    func writeUserCourses(_ courses: [WidgetUserCourse]) throws {
        let encoder = JSONEncoder()
        let dataToSave = try encoder.encode(courses)
        try dataToSave.write(to: self.archiveURL, options: .atomicWrite)
    }

    func readUserCourses() -> [WidgetUserCourse] {
        do {
            let codeData = try Data(contentsOf: self.archiveURL)

            let decoder = JSONDecoder()
            let courses = try decoder.decode([WidgetUserCourse].self, from: codeData)

            return courses
        } catch {
            print("WidgetContentFileManager: failed readUserCourses with error = \(error)")
        }

        return []
    }
}
