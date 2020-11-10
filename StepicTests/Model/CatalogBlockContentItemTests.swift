@testable
import Stepic

import Nimble
import Quick
import SwiftyJSON

class CatalogBlockContentItemSpec: QuickSpec {
    override func spec() {
        describe("CatalogBlockContentItem") {
            describe("NSSecureCoding") {
                func makeTemporaryPath(name: String) -> URL {
                    let temporaryDirectoryPath = NSTemporaryDirectory() as NSString
                    return URL(fileURLWithPath: temporaryDirectoryPath.appendingPathComponent(name))
                }

                it("full_course_lists encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: JSONResponse.fullCourseLists.stringValue)
                    let contentItem = FullCourseListsCatalogBlockContentItem(json: json)
                    let fileURL = makeTemporaryPath(name: "full_course_lists_content_item")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: contentItem,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedContentItem = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! FullCourseListsCatalogBlockContentItem

                    // Then
                    expect(contentItem.id) == unarchivedContentItem.id
                    expect(contentItem.title) == unarchivedContentItem.title
                    expect(contentItem.descriptionString) == unarchivedContentItem.descriptionString
                    expect(contentItem.courses) == unarchivedContentItem.courses
                    expect(contentItem.coursesCount) == unarchivedContentItem.coursesCount
                }

                it("simple_course_lists encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: JSONResponse.simpleCourseLists.stringValue)
                    let contentItem = SimpleCourseListsCatalogBlockContentItem(json: json)
                    let fileURL = makeTemporaryPath(name: "simple_course_lists_content_item")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: contentItem,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedContentItem = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! SimpleCourseListsCatalogBlockContentItem

                    // Then
                    expect(contentItem.id) == unarchivedContentItem.id
                    expect(contentItem.title) == unarchivedContentItem.title
                    expect(contentItem.descriptionString) == unarchivedContentItem.descriptionString
                    expect(contentItem.courses) == unarchivedContentItem.courses
                    expect(contentItem.coursesCount) == unarchivedContentItem.coursesCount
                }

                it("authors encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: JSONResponse.authors.stringValue)
                    let contentItem = AuthorsCatalogBlockContentItem(json: json)
                    let fileURL = makeTemporaryPath(name: "authors_content_item")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: contentItem,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedContentItem = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! AuthorsCatalogBlockContentItem

                    // Then
                    expect(contentItem.id) == unarchivedContentItem.id
                    expect(contentItem.isOrganization) == unarchivedContentItem.isOrganization
                    expect(contentItem.fullName) == unarchivedContentItem.fullName
                    expect(contentItem.alias).to(beNil())
                    expect(unarchivedContentItem.alias).to(beNil())
                    expect(contentItem.avatar) == unarchivedContentItem.avatar
                    expect(contentItem.createdCoursesCount) == unarchivedContentItem.createdCoursesCount
                    expect(contentItem.followersCount) == unarchivedContentItem.followersCount
                }
            }
        }
    }
}

private enum JSONResponse {
    case fullCourseLists
    case simpleCourseLists
    case authors

    var stringValue: String {
        switch self {
        case .fullCourseLists:
            return """
{
    "id": 1,
    "title": "Новые курсы",
    "description": "",
    "courses": [
        51904,
        56495,
        82176,
        84952,
        82799,
        71402,
        56594,
        84101,
        82893,
        78471,
        69599
    ],
    "courses_count": 34
}
"""
        case .simpleCourseLists:
            return """
{
    "id": 51,
    "title": "Гуманитарные науки",
    "description": "",
    "courses": [
        51,
        578,
        720,
        1564,
        1565,
        1655,
        1587,
        3141,
        6303,
        2438,
        8327
    ],
    "courses_count": 53
}
"""
        case .authors:
            return """
{
    "id": 26533986,
    "is_organization": false,
    "full_name": "Ляйсан Хутова",
    "alias": null,
    "avatar": "https://stepik.org/media/users/26533986/avatar.png?1586183748",
    "created_courses_count": 7,
    "followers_count": 99425
}
"""
        }
    }
}
