@testable
import Stepic

import Nimble
import Quick
import SwiftyJSON

class CatalogBlockSpec: QuickSpec {
    override func spec() {
        describe("CatalogBlock") {
            describe("JSON parsing") {
                it("parses full_course_lists") {
                    // Given
                    let json = JSON(parseJSON: JSONResponse.fullCourseLists.stringValue)

                    // When
                    let catalogBlock = CatalogBlock(json: json)

                    // Then
                    expect(catalogBlock.id) == 5
                    expect(catalogBlock.position) == 2
                    expect(catalogBlock.title) == "Онлайн-курсы"
                    expect(catalogBlock.descriptionString) == ""
                    expect(catalogBlock.language) == "ru"
                    expect(catalogBlock.kind!) == .fullCourseLists
                    expect(catalogBlock.appearance!) == .default
                    expect(catalogBlock.isTitleVisible) == true

                    let content = catalogBlock.content as! [FullCourseListsCatalogBlockContentItem]
                    expect(content.count) == 2
                    expect(content[0].id) == 1
                    expect(content[0].title) == "Новые курсы"
                    expect(content[0].descriptionString) == ""
                    expect(content[0].courses) == [
                        51904, 56495, 82176, 84952, 82799, 71402, 56594, 84101, 82893, 78471, 69599
                    ]
                    expect(content[0].coursesCount) == 34
                }

                it("parses simple_course_lists") {
                    // Given
                    let json = JSON(parseJSON: JSONResponse.simpleCourseLists.stringValue)

                    // When
                    let catalogBlock = CatalogBlock(json: json)

                    // Then
                    expect(catalogBlock.id) == 7
                    expect(catalogBlock.position) == 4
                    expect(catalogBlock.title) == "Предметы"
                    expect(catalogBlock.descriptionString) == ""
                    expect(catalogBlock.language) == "ru"
                    expect(catalogBlock.kind!) == .simpleCourseLists
                    expect(catalogBlock.appearance!) == .simpleCourseListsGrid
                    expect(catalogBlock.isTitleVisible) == true

                    let content = catalogBlock.content as! [SimpleCourseListsCatalogBlockContentItem]
                    expect(content.count) == 2
                    expect(content[0].id) == 51
                    expect(content[0].title) == "Гуманитарные науки"
                    expect(content[0].descriptionString) == ""
                    expect(content[0].courses) == [
                        51, 578, 720, 1564, 1565, 1655, 1587, 3141, 6303, 2438, 8327
                    ]
                    expect(content[0].coursesCount) == 53
                }

                it("parses authors") {
                    // Given
                    let json = JSON(parseJSON: JSONResponse.authors.stringValue)

                    // When
                    let catalogBlock = CatalogBlock(json: json)

                    // Then
                    expect(catalogBlock.id) == 4
                    expect(catalogBlock.position) == 15
                    expect(catalogBlock.title) == "Авторы курсов"
                    expect(catalogBlock.descriptionString) == ""
                    expect(catalogBlock.language) == "ru"
                    expect(catalogBlock.kind!) == .authors
                    expect(catalogBlock.appearance!) == .default
                    expect(catalogBlock.isTitleVisible) == true

                    let content = catalogBlock.content as! [AuthorsCatalogBlockContentItem]
                    expect(content.count) == 1
                    expect(content[0].id) == 26533986
                    expect(content[0].isOrganization) == false
                    expect(content[0].fullName) == "Ляйсан Хутова"
                    expect(content[0].alias).to(beNil())
                    expect(content[0].avatar) == "https://stepik.org/media/users/26533986/avatar.png?1586183748"
                    expect(content[0].createdCoursesCount) == 7
                    expect(content[0].followersCount) == 99425
                }

                it("parses recommended_courses") {
                    // Given
                    let json = JSON(parseJSON: JSONResponse.recommendedCourses.stringValue)

                    // When
                    let catalogBlock = CatalogBlock(json: json)

                    // Then
                    expect(catalogBlock.id) == 47
                    expect(catalogBlock.position) == 999
                    expect(catalogBlock.title) == "Персональные рекомендации"
                    expect(catalogBlock.descriptionString) == ""
                    expect(catalogBlock.language) == "ru"
                    expect(catalogBlock.kind!) == .recommendedCourses
                    expect(catalogBlock.appearance!) == .default
                    expect(catalogBlock.isTitleVisible) == true
                    expect(catalogBlock.content.isEmpty) == true
                }

                it("not parses organizations content") {
                    // Given
                    let json = JSON(parseJSON: JSONResponse.organizations.stringValue)

                    // When
                    let catalogBlock = CatalogBlock(json: json)

                    // Then
                    expect(catalogBlock.id) == 3
                    expect(catalogBlock.position) == 3
                    expect(catalogBlock.title) == "Размещают курсы на Stepik"
                    expect(catalogBlock.descriptionString) == ""
                    expect(catalogBlock.language) == "ru"
                    expect(catalogBlock.kindString) == "organizations"
                    expect(catalogBlock.kind).to(beNil())
                    expect(catalogBlock.appearance!) == .default
                    expect(catalogBlock.isTitleVisible) == true
                    expect(catalogBlock.content.isEmpty) == true
                }
            }
        }
    }
}

private enum JSONResponse {
    case fullCourseLists
    case simpleCourseLists
    case authors
    case organizations
    case recommendedCourses

    var stringValue: String {
        switch self {
        case .fullCourseLists:
            return """
{
    "id": 5,
    "position": 2,
    "title": "Онлайн-курсы",
    "description": "",
    "language": "ru",
    "platform": 1,
    "kind": "full_course_lists",
    "appearance": "default",
    "is_title_visible": true,
    "content": [
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
        },
        {
            "id": 49,
            "title": "Популярные курсы",
            "description": "",
            "courses": [
                58852,
                67,
                363,
                7798,
                38218,
                63054,
                76,
                5482,
                512,
                80971,
                9737
            ],
            "courses_count": 1829
        }
    ]
}
"""
        case .simpleCourseLists:
            return """
{
    "id": 7,
    "position": 4,
    "title": "Предметы",
    "description": "",
    "language": "ru",
    "platform": 1,
    "kind": "simple_course_lists",
    "appearance": "simple_course_lists_grid",
    "is_title_visible": true,
    "content": [
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
        },
        {
            "id": 4,
            "title": "Статистика и анализ данных",
            "description": "",
            "courses": [
                76,
                129,
                326,
                401,
                497,
                524,
                579,
                701,
                724,
                1878,
                2152
            ],
            "courses_count": 18
        }
    ]
}
"""
        case .authors:
            return """
{
    "id": 4,
    "position": 15,
    "title": "Авторы курсов",
    "description": "",
    "language": "ru",
    "platform": 1,
    "kind": "authors",
    "appearance": "default",
    "is_title_visible": true,
    "content": [
        {
            "id": 26533986,
            "is_organization": false,
            "full_name": "Ляйсан Хутова",
            "alias": null,
            "avatar": "https://stepik.org/media/users/26533986/avatar.png?1586183748",
            "created_courses_count": 7,
            "followers_count": 99425
        }
    ]
}
"""
        case .organizations:
            return """
{
    "id": 3,
    "position": 3,
    "title": "Размещают курсы на Stepik",
    "description": "",
    "language": "ru",
    "platform": 1,
    "kind": "organizations",
    "appearance": "default",
    "is_title_visible": true,
    "content": [
        {
            "id": 48,
            "is_organization": false,
            "full_name": "Yu Lin",
            "alias": null,
            "avatar": "https://stepik.org/users/48/3b62a20672e02189428ed445ef67798772678272/avatar.svg",
            "created_courses_count": 0,
            "followers_count": 0
        }
    ]
}
"""
        case .recommendedCourses:
            return """
{
    "id": 47,
    "position": 999,
    "title": "Персональные рекомендации",
    "description": "",
    "details_url": "",
    "cover": null,
    "language": "ru",
    "platform": 3,
    "kind": "recommended_courses",
    "appearance": "default",
    "is_title_visible": true,
    "content": []
}
"""
        }
    }
}
