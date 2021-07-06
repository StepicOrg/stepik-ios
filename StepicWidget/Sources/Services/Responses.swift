import Foundation

struct Meta: Decodable {
    let page: Int
    let has_next: Bool
    let has_previous: Bool
}

// MARK: user-courses

struct UserCoursesResponse: Decodable {
    let meta: Meta
    let userCourses: [UserCourse]

    enum CodingKeys: String, CodingKey {
        case meta
        case userCourses = "user-courses"
    }
}

struct UserCourse: Decodable {
    let id: Int
    let course: Int
    let last_viewed: String?

    var lastViewed: Date {
        if let lastViewedTimeString = self.last_viewed,
           let timeInterval = TimeInterval(timeString: lastViewedTimeString) {
            return Date(timeIntervalSince1970: timeInterval)
        }
        return Date()
    }
}

// MARK: courses

struct CoursesResponse: Decodable {
    let meta: Meta
    let courses: [Course]
}

struct Course: Decodable {
    let id: Int
    let summary: String?
    let title: String?
    let progress: String?
    let cover: String?

    var coverURLString: String? {
        if let cover = self.cover {
            return "\(WidgetConstants.URL.stepikURL)\(cover)"
        }
        return nil
    }
}

// MARK: progresses

struct ProgressesResponse: Decodable {
    let meta: Meta
    let progresses: [Progress]
}

struct Progress: Decodable {
    let id: String
    let n_steps: Int
    let n_steps_passed: Int

    var percentPassed: Float {
        self.n_steps != 0
            ? Float(self.n_steps_passed) / Float(self.n_steps) * 100
            : 100.0
    }
}
