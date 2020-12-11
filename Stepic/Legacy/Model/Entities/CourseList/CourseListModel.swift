//
//  CourseList.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import PromiseKit
import SwiftyJSON

final class CourseListModel: NSManagedObject, IDFetchable {
    typealias IdType = Int

    var language: ContentLanguage { ContentLanguage(languageString: self.languageString) }

    required convenience init(json: JSON) {
        self.init()
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.title = json[JSONKey.title.rawValue].stringValue
        self.listDescription = json[JSONKey.description.rawValue].stringValue
        self.position = json[JSONKey.position.rawValue].intValue
        self.languageString = json[JSONKey.language.rawValue].stringValue
        self.coursesArray = json[JSONKey.courses.rawValue].arrayObject as! [Int]
        self.similarAuthorsArray = json[JSONKey.similarAuthors.rawValue].arrayObject as? [Int] ?? []
        self.similarCourseListsArray = json[JSONKey.similarCourseLists.rawValue].arrayObject as? [Int] ?? []
    }

    static func fetchAsync(ids: [CourseListModel.IdType]) -> Guarantee<[CourseListModel]> {
        DatabaseFetchService.fetchAsync(entityName: "CourseList", ids: ids)
    }

    enum JSONKey: String {
        case id
        case title
        case description
        case position
        case language
        case courses
        case similarAuthors = "similar_authors"
        case similarCourseLists = "similar_course_lists"
    }
}
