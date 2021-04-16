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

            it("persists full_course_lists") {
                // Given
                let json = TestData.fullCourseListsCatalogBlock
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
                expect(fetchedCatalogBlock.kind) == CatalogBlockKind.fullCourseLists.rawValue
                expect(fetchedCatalogBlock.appearance) == CatalogBlockAppearance.default.rawValue
                expect(fetchedCatalogBlock.isTitleVisible) == true
                expect(fetchedCatalogBlock.content.isEmpty) == false
                expect(fetchedCatalogBlock.content == catalogBlock.content) == true
            }

            it("persists simple_course_lists") {
                // Given
                let json = TestData.simpleCourseListsCatalogBlock
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

                expect(fetchedCatalogBlock.id) == 7
                expect(fetchedCatalogBlock.position) == 4
                expect(fetchedCatalogBlock.title) == "Предметы"
                expect(fetchedCatalogBlock.descriptionString) == ""
                expect(fetchedCatalogBlock.language) == "ru"
                expect(fetchedCatalogBlock.kind) == CatalogBlockKind.simpleCourseLists.rawValue
                expect(fetchedCatalogBlock.appearance) == CatalogBlockAppearance.simpleCourseListsGrid.rawValue
                expect(fetchedCatalogBlock.isTitleVisible) == true
                expect(fetchedCatalogBlock.content.isEmpty) == false
                expect(fetchedCatalogBlock.content == catalogBlock.content) == true
            }

            it("persists authors") {
                // Given
                let json = TestData.authorsCatalogBlock
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

                expect(fetchedCatalogBlock.id) == 4
                expect(fetchedCatalogBlock.position) == 15
                expect(fetchedCatalogBlock.title) == "Авторы курсов"
                expect(fetchedCatalogBlock.descriptionString) == ""
                expect(fetchedCatalogBlock.language) == "ru"
                expect(fetchedCatalogBlock.kind) == CatalogBlockKind.authors.rawValue
                expect(fetchedCatalogBlock.appearance) == CatalogBlockAppearance.default.rawValue
                expect(fetchedCatalogBlock.isTitleVisible) == true
                expect(fetchedCatalogBlock.content.isEmpty) == false
                expect(fetchedCatalogBlock.content == catalogBlock.content) == true
            }

            it("persists recommended_courses") {
                // Given
                let json = TestData.recommendedCoursesCatalogBlock
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

                expect(fetchedCatalogBlock.id) == 47
                expect(fetchedCatalogBlock.position) == 999
                expect(fetchedCatalogBlock.title) == "Персональные рекомендации"
                expect(fetchedCatalogBlock.descriptionString) == ""
                expect(fetchedCatalogBlock.language) == "ru"
                expect(fetchedCatalogBlock.kind) == CatalogBlockKind.recommendedCourses.rawValue
                expect(fetchedCatalogBlock.appearance) == CatalogBlockAppearance.default.rawValue
                expect(fetchedCatalogBlock.isTitleVisible) == true
                expect(fetchedCatalogBlock.content.isEmpty) == true
            }

            it("persists specializations_stepik_academy") {
                // Given
                let json = TestData.specializationsStepikAcademyCatalogBlock
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

                expect(fetchedCatalogBlock.id) == 15
                expect(fetchedCatalogBlock.position) == 7
                expect(fetchedCatalogBlock.title) == "Stepik Academy"
                expect(fetchedCatalogBlock.descriptionString.isEmpty) == true
                expect(fetchedCatalogBlock.language) == "ru"
                expect(fetchedCatalogBlock.kind) == CatalogBlockKind.specializations.rawValue
                expect(fetchedCatalogBlock.appearance) == CatalogBlockAppearance.specializationsStepikAcademy.rawValue
                expect(fetchedCatalogBlock.isTitleVisible) == true
                expect(fetchedCatalogBlock.content.isEmpty) == false
                expect(fetchedCatalogBlock.content == catalogBlock.content) == true
            }
        }
    }
}
