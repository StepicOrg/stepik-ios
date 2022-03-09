@testable
import StepikModel

import XCTest

final class CertificateTests: XCTestCase {
    func testDeserializeJSON() throws {
        // Given
        let jsonString = """
        {
          "id": 135341,
          "user": 21612976,
          "course": 191,
          "issue_date": "2018-10-18T13:17:28Z",
          "update_date": null,
          "grade": 100,
          "type": "distinction",
          "url": "https://stepik.org/certificate/dadf42174f0da11a271053a4354932f09ae9dea8.pdf",
          "preview_url": "https://stepik.org/certificate/dadf42174f0da11a271053a4354932f09ae9dea8.png",
          "is_public": true,
          "user_rank": 1,
          "user_rank_max": 48317,
          "leaderboard_size": 112599,
          "saved_fullname": "Ivan Magda",
          "edits_count": 0,
          "allowed_edits_count": 1,
          "course_title": "Безопасность в интернете",
          "course_is_public": true,
          "course_language": "ru",
          "is_with_score": true
        }
        """
        let jsonData = jsonString.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        let certificate = try decoder.decode(Certificate.self, from: jsonData)

        // Then
        XCTAssertEqual(certificate.id, 135341)
        XCTAssertEqual(certificate.userID, 21612976)
        XCTAssertEqual(certificate.courseID, 191)
        XCTAssertNotNil(certificate.issueDate)
        XCTAssertNil(certificate.updateDate)
        XCTAssertEqual(certificate.grade, 100)
        XCTAssertEqual(certificate.typeString, "distinction")
        XCTAssertEqual(certificate.type, .distinction)
        XCTAssertEqual(
            certificate.urlString,
            "https://stepik.org/certificate/dadf42174f0da11a271053a4354932f09ae9dea8.pdf"
        )
        XCTAssertEqual(
            certificate.previewURLString,
            "https://stepik.org/certificate/dadf42174f0da11a271053a4354932f09ae9dea8.png"
        )
        XCTAssertEqual(certificate.isPublic, true)
        XCTAssertEqual(certificate.userRank, 1)
        XCTAssertEqual(certificate.userRankMax, 48317)
        XCTAssertEqual(certificate.leaderboardSize, 112599)
        XCTAssertEqual(certificate.savedFullName, "Ivan Magda")
        XCTAssertEqual(certificate.editsCount, 0)
        XCTAssertEqual(certificate.allowedEditsCount, 1)
        XCTAssertEqual(certificate.courseTitle, "Безопасность в интернете")
        XCTAssertTrue(certificate.courseIsPublic)
        XCTAssertEqual(certificate.courseLanguage, "ru")
        XCTAssertTrue(certificate.isWithScore)
    }

    func testSerializeToJSON() throws {
        // Given
        let certificate = Certificate(
            id: 135341,
            userID: 21612976,
            courseID: 191,
            issueDate: DateFormatter.parsedStepikISO8601Date(from: "2018-10-18T13:17:28Z"),
            updateDate: nil,
            grade: 100,
            typeString: "distinction",
            urlString: "https://stepik.org/certificate/dadf42174f0da11a271053a4354932f09ae9dea8.pdf",
            previewURLString: "https://stepik.org/certificate/dadf42174f0da11a271053a4354932f09ae9dea8.png",
            isPublic: true,
            userRank: 1,
            userRankMax: 48317,
            leaderboardSize: 112599,
            savedFullName: "Ivan Magda",
            editsCount: 0,
            allowedEditsCount: 1,
            courseTitle: "Безопасность в интернете",
            courseIsPublic: true,
            courseLanguage: "ru",
            isWithScore: true
        )

        // When
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(certificate)
        let sameCertificate = try decoder.decode(Certificate.self, from: data)

        // Then
        XCTAssertEqual(certificate, sameCertificate)
    }
}
