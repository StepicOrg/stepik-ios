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
                    let json = TestData.fullCourseListsCatalogBlock

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
                    let json = TestData.simpleCourseListsCatalogBlock

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
                    let json = TestData.authorsCatalogBlock

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
                    let json = TestData.recommendedCoursesCatalogBlock

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

                it("parses specializations_stepik_academy") {
                    // Given
                    let json = TestData.specializationsStepikAcademyCatalogBlock

                    // When
                    let catalogBlock = CatalogBlock(json: json)

                    // Then
                    expect(catalogBlock.id) == 15
                    expect(catalogBlock.position) == 7
                    expect(catalogBlock.title) == "Stepik Academy"
                    expect(catalogBlock.descriptionString.isEmpty) == true
                    expect(catalogBlock.language) == "ru"
                    expect(catalogBlock.kind!) == .specializations
                    expect(catalogBlock.appearance!) == .specializationsStepikAcademy
                    expect(catalogBlock.isTitleVisible) == true
                    expect(catalogBlock.content.count) == 2

                    let content = catalogBlock.content as! [SpecializationsCatalogBlockContentItem]
                    expect(content.count) == 2
                    expect(content[0].id) == 6
                    expect(content[0].title) == "Big Data for Data Science"
                    expect(content[0].descriptionString.isEmpty) == true
                    expect(content[0].detailsURLString) == "http://academy.stepik.org/big-data?utm_source=stepik&utm_medium=catalog&utm_campaign=catalog"
                    expect(content[0].priceString) == "35000.00"
                    expect(content[0].discountString) == "6000.00"
                    expect(content[0].currencyString) == "RUB"
                    expect(content[0].startDate) == Parser.dateFromTimedateJSON(JSON("2021-02-12T03:00:01Z"))!
                    expect(content[0].endDate).to(beNil())
                    expect(content[0].durationString) == "6 недель"
                }

                it("not parses organizations content") {
                    // Given
                    let json = TestData.organizationsCatalogBlock

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
