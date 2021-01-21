@testable
import Stepic

import CoreData
import Nimble
import Quick
import SwiftyJSON

class CatalogBlockEntitySpec: QuickSpec {
    override func spec() {
        describe("CatalogBlockEntity") {
            var testCoreDataStack: TestCoreDataStack!

            beforeEach {
                testCoreDataStack = TestCoreDataStack()
            }

            it("persists CatalogBlockEntity") {
                // Given
                let json = JSON(parseJSON: JSONResponse.fullCourseLists.stringValue)
                let catalogBlock = CatalogBlock(json: json)

                // When
                _ = CatalogBlockEntity(
                    catalogBlock: catalogBlock,
                    managedObjectContext: testCoreDataStack.managedObjectContext
                )
                testCoreDataStack.saveContext()

                // Then
                let request = CatalogBlockEntity.fetchRequest
                request.sortDescriptors = CatalogBlockEntity.defaultSortDescriptors

                let catalogBlocks = try! testCoreDataStack.managedObjectContext.fetch(request)
                expect(catalogBlocks.count) == 1

                let fetchedCatalogBlock = catalogBlocks[0]

                expect(fetchedCatalogBlock.id) == 5
                expect(fetchedCatalogBlock.position) == 2
                expect(fetchedCatalogBlock.title) == "Онлайн-курсы"
                expect(fetchedCatalogBlock.descriptionString) == ""
                expect(fetchedCatalogBlock.language) == "ru"
                expect(fetchedCatalogBlock.kind) == "full_course_lists"
                expect(fetchedCatalogBlock.appearance) == "default"
                expect(fetchedCatalogBlock.isTitleVisible) == true
                expect(fetchedCatalogBlock.content.isEmpty) == false
                expect(fetchedCatalogBlock.content == catalogBlock.content) == true
            }
        }
    }
}

private enum JSONResponse {
    case fullCourseLists

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
        },
        {
            "id": 50,
            "title": "Stepik рекомендует 👍",
            "description": "",
            "courses": [
                51562,
                575,
                68712,
                56365,
                4852,
                738
            ],
            "courses_count": 6
        },
        {
            "id": 12,
            "title": "Программирование для начинающих",
            "description": "",
            "courses": [
                363,
                2223,
                67,
                58852,
                58973,
                217,
                38218,
                5482,
                54403,
                187,
                3078
            ],
            "courses_count": 21
        }
    ]
}
"""
        }
    }
}
