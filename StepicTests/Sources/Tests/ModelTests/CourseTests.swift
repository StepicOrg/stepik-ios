@testable
import Stepic

import Nimble
import Quick
import SwiftyJSON

class CourseSpec: QuickSpec {
    override func spec() {
        describe("Course") {
            describe("JSON parsing") {
                it("parses with default_promo_code fields") {
                    // Given
                    let json = TestData.courseWithDefaultPromoCode

                    // When
                    let course = Course(json: json)

                    // Then
                    expect(course.id) == 191
                    expect(course.defaultPromoCodeName) == "SALE100"
                    expect(course.defaultPromoCodePrice) == 2790.0
                    expect(course.defaultPromoCodeDiscount) == 100.0
                    expect(course.defaultPromoCodeExpireDate).toNot(beNil())
                }

                it("parses without default_promo_code fields") {
                    // Given
                    let json = TestData.courseWithoutDefaultPromoCode

                    // When
                    let course = Course(json: json)

                    // Then
                    expect(course.id) == 191
                    expect(course.defaultPromoCodeName).to(beNil())
                    expect(course.defaultPromoCodePrice).to(beNil())
                    expect(course.defaultPromoCodeDiscount).to(beNil())
                    expect(course.defaultPromoCodeExpireDate).to(beNil())
                }
            }
        }
    }
}
